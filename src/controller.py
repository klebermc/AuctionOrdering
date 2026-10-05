
#!/usr/bin/env python3

# Common Python libraries
import numpy as np

import matplotlib.pyplot as plt

from enum import Enum

# ROS python API
import rospy

# geometry messages
from geometry_msgs.msg import Point, Pose, Twist

NUM_ROBOTS = 2

#/hexapod0/pose
#/hexapod0/setpoint

class Flocking_Based_Controller:
    def done(self, POS, Setpoint):
        done = self.norm(POS-Setpoint) < 0.1
        return done

    def flocking_based_controller(self, POS, VEL, Setpoint, Pos_Other_Robots, Robot_Radius, robot_dist, EndGameTrigger):
        c_gamma_1=0.1
        c_gamma_2=0.1
        c_beta_1=0.1
        c_beta_2=0.1

        epslon=0.5;
        n=3;

        TgtVEL   = np.array([0.0,0.0,0.0]);
        u_gamma  = np.array([0.0,0.0,0.0]);
        u_beta   = np.array([0.0,0.0,0.0]);
        pos_beta = np.array([0.0,0.0,0.0]);

        Pos_Other_Robots=np.array(Pos_Other_Robots, ndmin=2);

        pos_beta[0]=Setpoint[0]
        pos_beta[1]=Setpoint[1]

        POS[2]=Setpoint[2];

        QntOtherRobots = Pos_Other_Robots.shape[0];

        for i in range(0,QntOtherRobots):
            Pos_Other_Robot = np.array(Pos_Other_Robots[i]);
            Pos_Other_Robot[2]=POS[2]; # THIS WAY I WILL AVOID REGARDLESS HEIGHT

            # ------------- Other Robot Zone  ----------
            sigma_d_obs=self.sigma_norm(Robot_Radius[i]);
            int_range_r_obs=robot_dist;
            sigma_int_range_obs=self.sigma_norm(int_range_r_obs);
            # print(sigma_d_obs,int_range_r_obs,sigma_int_range_obs)


            #To run simulation faster,
            #avoid the calculations if the robot is out of range
            if self.norm(POS - Pos_Other_Robot)<int_range_r_obs+Robot_Radius[i]:
                # print(" robot{} = {:.3f}".format(int(i),self.norm(POS - Pos_Other_Robot)));
                mu = Robot_Radius[i]/self.norm(POS - Pos_Other_Robot);      # obtain the vector from agent to object
                a_k = np.array((POS - Pos_Other_Robot)/self.norm(POS - Pos_Other_Robot));
                P=np.identity(n) - a_k @ (a_k.T);                   #matrix multiply
                pos_beta=mu*POS+(1-mu)*Pos_Other_Robot;         #position of beta agent (#olfati-saber modeling)
                #print(pos_beta,P,np.identity(n), a_k , a_k.T,  a_k @ (a_k.T))
                pos_beta[2]=POS[2]

                vel_beta=mu*(P@VEL);                         #velocity of beta agent (#olfati-saber modeling)
                if self.norm(vel_beta)!=0:
                    v=vel_beta/self.norm(vel_beta);
                else:
                    v=vel_beta*0;
                v=v*self.norm(VEL);
                # print(VEL, vel_beta,  v);

                diff=pos_beta-POS;
                sigma_diff=self.sigma_norm(diff);
                sigma1=self.sigma_1(sigma_diff-sigma_d_obs);
                rho=self.rho_h(sigma_diff/sigma_int_range_obs);

                phi_beta = rho*(sigma1-1);
                nij = diff/np.sqrt(1+epslon*(pow(self.norm(diff),2)));
                b_ik = rho;

                pos_comp = c_beta_1*phi_beta*nij;
                vel_comp = c_beta_2*b_ik*(vel_beta-VEL);

                u_beta = u_beta + pos_comp  + vel_comp ;
                u_beta[2]=0;

                # print(nij, self.norm(pos_comp), pos_comp, b_ik, self.norm(vel_comp) ,vel_comp)

                # pos_beta_all=np.concatenate((pos_beta_all,pos_beta),axis=0)

        if EndGameTrigger==1:
            u_beta=u_beta*0;

        # -------- TARGET controller --------
        # sInPos=self.sigma_1(Setpoint[0:2]-POS[0:2])
        # u_gamma[0] = c_gamma_1*sInPos[0] + c_gamma_2*(TgtVEL[0]-VEL[0])
        # u_gamma[1] = c_gamma_1*sInPos[1] + c_gamma_2*(TgtVEL[1]-VEL[1])
        u_gamma = c_gamma_1*self.sigma_1(Setpoint-POS) + c_gamma_2*(TgtVEL-VEL)
        u_gamma[2]=0

        AccCmdE = u_gamma + u_beta

        return AccCmdE , u_gamma , u_beta, pos_beta

    def sigma_norm(self,input):
        epslon=0.5;
        return (1/epslon)*(np.sqrt(1+epslon*(pow(self.norm(input),2)))-1);

    def sigma_1(self,input):
        return input/(np.sqrt(1+pow(self.norm(input),2)));

    def rho_h(self,input):
        if input >= 0 and input < 0.5:
            rho=1;
        elif input >= 0.5 and input<1:
            rho= 0.5 * (1 + np.cos( np.pi * ((input-0.5)/(1-0.5))));
        else :
            rho=0;
        return rho;

    def normAB(self,a,b):
        return np.linalg.norm(a - b)

    def norm(self,a):
        return np.linalg.norm(a)

    def saturate(self,val, Vmin, Vmax):
        return np.max([np.min([val,Vmax]),Vmin])

    def saturateVector(self,val, Vmin, Vmax):
        mag=self.norm(val)
        theta=np.arctan2(val[1],val[0])
        sat_mag=np.max([np.min([mag,Vmax]),Vmin])
        return np.array([np.cos(theta)*sat_mag,np.sin(theta)*sat_mag,])

class RobotClass:

    def __init__(self,i):
        print("Initializing the instance = ",i)
        # initialize the subscribers now.
        self.pos_sub = rospy.Subscriber("/hexapod"+str(i)+"/pose", Pose, self.PosCallback)
        self.vel_sub = rospy.Subscriber("/hexapod"+str(i)+"/velocity", Twist, self.VelCallback)

        # initialize the publishers now.
        self.cmdvel_pub = rospy.Publisher("/hexapod"+str(i)+"/cmd_vel", Twist, queue_size=1)
        self.setpoint_pub = rospy.Publisher("/hexapod"+str(i)+"/setpoint",Point, queue_size=1)

        self.wp = np.array([0.0,0.0,0.0])

        self.position=np.array([0.0,0.0,0.0])
        self.orientation=np.array([0.0,0.0,0.0,0.0])
        self.velocity=np.array([0.0,0.0,0.0])
        self.ang_vel=np.array([0.0,0.0,0.0])
        self.id=i

    def PosCallback(self, Pose):
        #rospy.loginfo(str(self.id) + " - the pose is\n%s", Pose)
        self.position=np.array([Pose.position.x,Pose.position.y,Pose.position.z])
        self.orientation=np.array([Pose.orientation.x,Pose.orientation.y,Pose.orientation.z,Pose.orientation.w])

    def VelCallback(self, Twist):
        #rospy.loginfo(str(self.id) + " - the velocities are\n%s", Twist)
        self.velocity=np.array([Twist.linear.x,Twist.linear.y,Twist.linear.z])
        self.ang_vel=np.array([Twist.angular.x,Twist.angular.y,Twist.angular.z])

def main():
    robot={}
    for i in range(0,NUM_ROBOTS):
        # create a subscriber instance
        robot[i] = RobotClass(i)

    robot[0].wp[0]=2
    robot[1].wp[0]=-2

    # follow it up with a no-brainer sequence check
    print('Currently in the main function...')

    # initializing the subscriber node
    # rospy.init_node('listener', anonymous=True)
    # rospy.spin()

    ## USER SELECTABLE PARAMETERS
    # ROS loop rate
    hz = 10.0

    ## Simulation
    t = 0
    dt = 1/hz

    # initiate node
    rospy.init_node('controller_node', anonymous=True)
    rate = rospy.Rate(hz)

    fig = plt.figure()
    ax = plt.axes()
    plt.axis([-2,2,-2,2])
    plt.ion()
    plt.show()

#     # Setpoint publisher
#     sp_pub = rospy.Publisher('mavros/setpoint_raw/local', PositionTarget, queue_size=1)
#
    lastPos = []
    robot_dist=1

    PosController=Flocking_Based_Controller()

    while not rospy.is_shutdown():

        for i in range(0,NUM_ROBOTS):
            p = robot[i].position
            v = robot[i].velocity
            wp = robot[i].wp


            other_robots=np.empty((0,3), float)
            other_robots_sz=np.empty((0,1), float)
            k=0
            for j in range(0,NUM_ROBOTS):
                if j != i:
                    other_robots    =   np.append(other_robots,robot[j].position.reshape((1,3)))
                    other_robots_sz =   np.append(other_robots_sz,0.5)

            # if norm(p-wp)<1:
            #     EndGameTrigger=1
            #     if FB_Cont.norm(p-wp)<0.1:
            #         quit()
            # else:
            #     EndGameTrigger=0
            EndGameTrigger=0
            #controller
            a,ug,ub,pb = PosController.flocking_based_controller(p, v, wp, other_robots, other_robots_sz, robot_dist, EndGameTrigger)
            # print("Desired acc: ", a, " Magnitude: ", np.linalg.norm(a), " Distance Goal: ", np.linalg.norm(p-wp), " Vel: ", v )
            acc_cmd = PosController.saturateVector(a,0.0,0.5)
            commaded_vel = v[0:2] + acc_cmd[0:2]#*dt
            if i==0:
                print(i, " -> Desired acc: ", acc_cmd[0:2], ug[0:2], ub[0:2] , " desired vel: ", commaded_vel[0:2], v[0:2], " Distance Goal: ", np.linalg.norm(p-wp) )
            message=Twist()
            if i==1:
                commaded_vel=commaded_vel*0
            message.linear.x=commaded_vel[0]
            message.linear.y=commaded_vel[1]
            robot[i].cmdvel_pub.publish(message)

            message=Point()
            message.x=robot[i].wp[0]
            message.y=robot[i].wp[1]
            robot[i].setpoint_pub.publish(message)

            ax.scatter(robot[i].position[0],robot[i].position[1], color = 'black')
            if i==0:
                plt.arrow(robot[i].position[0],robot[i].position[1], commaded_vel[0],  commaded_vel[1], color = 'green')
                plt.arrow(robot[i].position[0],robot[i].position[1], v[0],  v[1], color = 'black')
                plt.arrow(robot[i].position[0],robot[i].position[1], acc_cmd[0],  acc_cmd[1], color = 'red')
                # plt.arrow(robot[i].position[0],robot[i].position[1], ug[0],  ug[1], color = 'black')
                plt.arrow(robot[i].position[0],robot[i].position[1], ub[0],  ub[1], color = 'blue')
            # ax.plot3D(Extract(tactic_D.p_1_history, 0),Extract(tactic_D.p_1_history, 1),Extract(tactic_D.p_1_history, 2), '-b')
            # ax.plot3D(Extract(tactic_A.p_A_history, 0),Extract(tactic_A.p_A_history, 1),Extract(tactic_A.p_A_history, 2), '-r')
            plt.draw()
            plt.pause(0.001)
        t = t + dt
        rate.sleep()

        # plt.show(block=False)

if __name__ == '__main__':
    try:
        main()
    except rospy.ROSInterruptException:
        pass
