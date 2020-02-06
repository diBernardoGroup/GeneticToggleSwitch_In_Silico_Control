package bControl;

import java.util.Vector;

import bBacterium.BSimControlledBacterium;
import bsim.BSim;

public class Controller {

	private double[] ref;
	private double aTcVal;
	private double IPTGVal;
	private BSim sim;
	public double D;
	private double Lc;
	private double Tw;
	public double curr_e;
	private double[] state_per;
	private double Ts;
	private double kp;
	private double ki;
	private double I;
	
	public Controller (double[] ref,double aTcVal,double IPTGVal,BSim sim,double Ts,double kp,double ki) {
		this.aTcVal=aTcVal;
		this.ref=ref;
		this.IPTGVal=IPTGVal;
		this.sim=sim;
		D=0.4;
		Tw=240;
		Lc=0;
		I=0;
		this.Ts=Ts;
		state_per=new double[2];
		curr_e=0;
		this.kp=kp;
		this.ki=ki;
	}
	
	
	public double Evaluate_Control(double e) {
		
		double time=sim.getTime()/60;
		double u_a;
		
		if (time>=Lc+Tw) {
			
			double thetaLac=31.93;
			double thetaTet=29.99;
			state_per[0]/=thetaLac;
			state_per[1]/=thetaTet;
			curr_e=project_error(state_per);
			I+=ki*curr_e*Tw;
			//I+=ki*curr_e*5;
			D+=kp*curr_e+I;
			
			
			
			Lc=Lc+Tw; // New Period
			state_per[0]=0;
			state_per[1]=0;

		}
		
		
		if (time<=Lc+(D*Tw)) {
			u_a=aTcVal;
		}else {
			u_a=0;
		}
		
		
        return u_a;
	}
	
	
	public double Evaluate_Error(Vector<BSimControlledBacterium> bacteria) {
		
		int i=0;
		int trk_cell=0;
		double trk_cell_y=bacteria.get(0).position.y;
		for (BSimControlledBacterium b : bacteria) {
            if(b.position.y<trk_cell_y) {
            	trk_cell=i;
            	trk_cell_y=b.position.y;
            }
            i++;
        }
		state_per[0]+=1/(Tw/Ts)*bacteria.get(trk_cell).y[2];
		state_per[1]+=1/(Tw/Ts)*bacteria.get(trk_cell).y[3];
		
		
		
		
		return curr_e;
		
		
	}
	
	
	
	public double getIPTGVal() {
		return IPTGVal;		
	}
	
	public double getaTcVal() {
		return aTcVal;		
	}
	
	
	private double project_error(double [] state) {
		
		
		double [] coeff= {-0.000143080985051931,0.0286497324849570,-1.78416305973329,35.9021400464512};
		
		double [] x=new double[10000];
		double [] y=new double[10000];
		double d_min_sp;
		double curr_d_sp;
		double d_min_state;
		double curr_d_state;
		int i_min_sp=0;
		int i_min_state=0;
		
		x[0]=0;
		y[0]=coeff[0]*Math.pow(x[0],3)+coeff[1]*Math.pow(x[0],2)+coeff[2]*x[0]+coeff[3];
		d_min_sp=Math.sqrt(Math.pow(x[0]-ref[0],2)+Math.pow(y[0]-ref[1],2));
		d_min_state=Math.sqrt(Math.pow(x[0]-state[0],2)+Math.pow(y[0]-state[1],2));
		
		
		for (int i=1;i<10000;i++) {
			x[i]=i*0.01;
			y[i]=coeff[0]*Math.pow(x[i],3)+coeff[1]*Math.pow(x[i],2)+coeff[2]*x[i]+coeff[3];
			curr_d_sp=Math.sqrt(Math.pow(x[i]-ref[0],2)+Math.pow(y[i]-ref[1],2));
			curr_d_state=Math.sqrt(Math.pow(x[i]-state[0],2)+Math.pow(y[i]-state[1],2));
			if (curr_d_sp<d_min_sp) {
				d_min_sp=curr_d_sp;
				i_min_sp=i;
			}
			if (curr_d_state<d_min_state) {
				d_min_state=curr_d_state;
				i_min_state=i;
			}
		}
		
		double errp=0;
		if (i_min_sp<i_min_state) {
			for (int i=i_min_sp;i<i_min_state;i++) {
				errp+=Math.sqrt(1+Math.pow((3*coeff[0]*Math.pow(x[i], 2)+2*coeff[1]*x[i]+coeff[2]),2))*0.01;
			}
			errp=-errp;
		}else {
			for (int i=i_min_state;i<i_min_sp;i++) {
				errp+=Math.sqrt(1+Math.pow((3*coeff[0]*Math.pow(x[i], 2)+2*coeff[1]*x[i]+coeff[2]),2))*0.01;
			}
		}
		return errp;
		
		
		
		
	}
	
	
	
	
}
