package bField;


import java.util.Vector;

import javax.vecmath.Vector3d;

import bBacterium.BSimControlledBacterium;
import bsim.BSim;
import bsim.ode.BSimOdeSystem;

public class ExternalMediumDyn implements BSimOdeSystem {

	// Number of equations in the system
	private int neq;
	
	//Bacteria currently active
	private Vector <BSimControlledBacterium> bacteriaIn;
	
	//Interaction parameters
	private double k;
	private int index;//Index of the state variable of the bacterium that has to be exchanged
	
	//Field Information
	private int [] box;
	private double [] dimention;
	
	
	
	public ExternalMediumDyn(Vector <BSimControlledBacterium> bacteriaIn,double k,int index,int[] box,double [] dimention,BSim sim) {
		
		neq=1;
		this.bacteriaIn=bacteriaIn;// list of bacteria in the box
		this.k=k; //kaTC or kIPTG
		this.index=index; //Index of aTC or IPTG depending on the Chemical field associated
		this.box=box; //The box whose dynamics i'm modeling
		this.dimention=dimention;//Dimensions of the box
		
	}
	
	
	
	@Override
	public double[] derivativeSystem(double t, double[] x) {
		double [] dx=new double[neq];
		
		dx[0]=0; //Initialize the derivative
		
		//Searching for bacteria in the current box
		for (int i=0;i<bacteriaIn.size();i++) {
			BSimControlledBacterium b=bacteriaIn.get(i); //Get a bacterium
			Vector3d p1=b.x1;//Get it's position
			Vector3d p2=b.x2;
			double xCoord=(p1.getX()+p2.getX())/2; //Get the x coordinate
			double yCoord=(p1.getY()+p2.getY())/2; //Get the y coordinate (GET THE CENTER OF THE BACTERIUM SEMPLIFICATION)
			double zCoord=(p1.getZ()+p2.getZ())/2; //Get the z coordinate
			if((xCoord>(box[0]*dimention[0]))&&(xCoord<((box[0]+1)*dimention[0]))) { //If i'm in the x range
				if(((yCoord>(box[1]*dimention[1]))&&(yCoord<((box[1]+1)*dimention[1])))) { //If i'm in the y range
					if(((zCoord>(box[2]*dimention[2]))&&(zCoord<((box[2]+1)*dimention[2])))) { //If i'm in the z range
						dx[0]=dx[0]+k*(b.y_fields[index]-x[0]);  //I can influence the dynamics
					}else {}
				}else {}
			}else {}
		}
		
		
		return dx;
	}

	@Override
	public double[] getICs() {
		double [] x0=new double[neq];
		
		x0[0]=0;
		
		return x0;
	}

	@Override
	public int getNumEq() {
		return neq;
	}
	
}
