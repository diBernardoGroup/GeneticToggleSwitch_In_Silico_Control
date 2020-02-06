package bField;

import java.util.Vector;

import bBacterium.*;
import bsim.BSim;
import bsim.BSimChemicalField;
import bsim.ode.BSimOdeSolver;

public class ControlledFIeld extends BSimChemicalField {

	//Dynamics Vector
	private ExternalMediumDyn [][][] extDyn;
	
	
	//Field Values
	private double [][][][] fieldValues;
	private double [][][][] newValues;
	
	//Control input
	private double Control;
	
	
	
	public ControlledFIeld(BSim sim, int[] boxes, double diffusivity, double decayRate, Vector <BSimControlledBacterium> Bacteria,double k,int index) {
		//Initialization 
		super(sim, boxes, diffusivity, decayRate);
		Control=0;
		
		//Vector for the external medium interaction with cells
		extDyn=new ExternalMediumDyn [boxes[0]] [boxes[1]] [boxes[2]];  //Vector of external dynamics for each box of the field

		
		//Initializing the dynamics in each box
		for (int i=0;i<boxes[0];i++) {
			for (int j=0;j<boxes[1];j++) {
				for (int kk=0;kk<boxes[2];kk++) {
					int [] indbox= {i,j,kk};  // Current box index
					if(j==0||j==(boxes[1]-1)) {
						extDyn[i][j][kk]=new ExternalMediumDyn(Bacteria,k,index,indbox,this.box,sim);
					}else {
						extDyn[i][j][kk]=new ExternalMediumDyn(Bacteria,k,index,indbox,this.box,sim);
					}
					
				}
			}
		}
		
		//Setting all the initial conditions of each box concentration
		fieldValues=new double [boxes[0]] [boxes[1]] [boxes[2]] [extDyn[0][0][0].getNumEq()];
		newValues=new double [boxes[0]] [boxes[1]] [boxes[2]] [extDyn[0][0][0].getNumEq()];
		
		//Setting the inital condition of each box
		for (int i=0;i<boxes[0];i++) {
			for (int j=0;j<boxes[1];j++) {
				for (int kk=0;kk<boxes[2];kk++) {
					fieldValues[i][j][kk]=extDyn[i][j][kk].getICs(); //Get the initial condition of the field 
					this.setConc(i, j, kk, fieldValues[i][j][kk][0]); // and sets its concentration (the dyn has only one value)
				}
			}
		}
		
		
	}
	
	
	public void updateValues() {
		//Updating the concetrations of each box
				for (int i=0;i<boxes[0];i++) {
					for (int j=0;j<boxes[1];j++) {
						for (int kk=0;kk<boxes[2];kk++) {
							if(j==0||j==(boxes[1]-1)) {
								if(Control<=0) {
									Control=0;
								}
								this.setConc(i, j, kk, Control);
							}else {
								
								fieldValues[i][j][kk]=new double [] {this.getConc(i, j, kk)};// Get the current concetrations (they are changed due to the diffusion and the degradation )
								newValues[i][j][kk] = BSimOdeSolver.rungeKutta45(extDyn[i][j][kk], sim.getTime()/60, fieldValues[i][j][kk] , sim.getDt()/60); //Update the value with the diffusion dynamics in the cells						
								
								
								if(newValues[i][j][kk][0]<0) {
									newValues[i][j][kk][0]=0;
								}
								
								this.setConc(i,j,kk,newValues[i][j][kk][0]); //Set the concentration of each box
							}
						}
					}
				}
	}
	
	
	public void setControl(double ctrl) {
		Control=ctrl;
	}
		
	
	

}
