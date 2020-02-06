package bDrawer;

import java.awt.Color;
import java.awt.Graphics2D;
import java.util.Vector;

import javax.vecmath.Vector3d;

import bsim.BSim;
import bsim.BSimChemicalField;
import bsim.draw.BSimP3DDrawer;
import processing.core.PConstants;
import processing.core.PGraphics3D;
import bBacterium.*;

public class My3DDrawer extends BSimP3DDrawer {
	//Active Bacteria
	private Vector<BSimControlledBacterium> bacteria;

	//Bounds
	private double simX;
	private double simY;
	
	//Fields
	private BSimChemicalField aTcField;
	private BSimChemicalField IPTGField;
	private double ref;
	
	//Graphs to display
	private double [] LacV;
	private double [] TetV;
	private double [] atcV;
	private double [] iptgV;
	private double [] contv;
	private double [] contlv;
	private double [] refv;
	private double [] reflv;
	private int current;
	
	
	public My3DDrawer(BSim sim, int width, int height,Vector<BSimControlledBacterium> bacteria,BSimChemicalField aTcField,BSimChemicalField IPTGField,double ref) {
		super(sim, width, height);
		this.bacteria=bacteria;
		simX=sim.getBound().getX();
		simY=sim.getBound().getY();
		//simZ=sim.getBound().getZ();
		this.aTcField=aTcField;
		this.IPTGField=IPTGField;
		
		//Display Values Initialization
		LacV=new double[(int)sim.getSimulationTime()/(60*1)+1];
		TetV=new double[(int)sim.getSimulationTime()/(60*1)+1];
		atcV=new double[(int)sim.getSimulationTime()/(60*1)+1];
		iptgV=new double[(int)sim.getSimulationTime()/(60*1)+1];
		contv=new double[(int)sim.getSimulationTime()/(60*1)+1];
		refv=new double[(int)sim.getSimulationTime()/(60*1)+1];
		contlv=new double[(int)sim.getSimulationTime()/(60*1)+1];
		reflv=new double[(int)sim.getSimulationTime()/(60*1)+1];
		current=0;
		this.ref=ref;
		
	}

	@Override
	public void scene(PGraphics3D p3d) {	
		
		p3d.ambientLight(128, 128, 128);
        p3d.directionalLight(128, 128, 128, 1, 1, -1);
		
		
		double thres=10;

		int cont=0;
		int contl=0;
		
		draw(aTcField,Color.ORANGE,(float)(255/100));
		draw(IPTGField,Color.PINK,(float)(255/1));
		
		atcV[current]=aTcField.getConc(0,0,0)/100;
		iptgV[current]=IPTGField.getConc(0,0,0)/1;
		
		for(BSimControlledBacterium b : bacteria) { //For each bacterium here
			
			
			int red=0;
			int green=0;
			double rateTL=b.y[2]/b.y[3]; //Lac on TetR
			//Color setting in dependance of The switching
			if(rateTL<=0.5) {
				red=255;
				contl++;
			}
			else {
				if(rateTL<thres) {
					red=255-(int) Math.floor(((rateTL/thres)*255)); //I set the color in a way taht it is red if it has not writched and green otherwise	
					green=(int) Math.floor(((rateTL/thres)*255));
				}
				else {
					green=255;
					cont++;
				}		
			}
			draw(b, new Color(red,green,0));
			LacV[current]=LacV[current]+b.y[2];
			TetV[current]=TetV[current]+b.y[3];
		}
		LacV[current]=LacV[current]/bacteria.size();
		TetV[current]=TetV[current]/bacteria.size();
		contv[current]=LacV[current]/TetV[current];
		
		
		//Disegno gli assi
		drawAxes((float)(boundCentre.x+bound.x/2+1.4),(float)boundCentre.y,(float)boundCentre.z);
		//Disegno la curva
		float maxy=2000;
		
		drawCurve((float)(boundCentre.x+bound.x/2+1.4),(float)boundCentre.y,(float)boundCentre.z,(float)(bound.x-1.3),(float)(-bound.y/2),(float)(sim.getSimulationTime()/(60*1)),(float)(maxy),0,255,0,LacV);
		drawCurve((float)(boundCentre.x+bound.x/2+1.4),(float)boundCentre.y,(float)boundCentre.z,(float)(bound.x-1.3),(float)(-bound.y/2),(float)(sim.getSimulationTime()/(60*1)),(float)(maxy),255,0,0,TetV);
		drawAxes((float)(boundCentre.x+bound.x/2+1.4),(float)(boundCentre.y+1.05*bound.y/2),(float)boundCentre.z);
		drawCurve((float)(boundCentre.x+bound.x/2+1.4),(float)(boundCentre.y+1.05*bound.y/2),(float)boundCentre.z,(float)(bound.x-1.3),(float)(-bound.y/2),(float)(sim.getSimulationTime()/(60*1)),(float)(1),0,255,0,atcV);
		drawCurve((float)(boundCentre.x+bound.x/2+1.4),(float)(boundCentre.y+1.05*bound.y/2),(float)boundCentre.z,(float)(bound.x-1.3),(float)(-bound.y/2),(float)(sim.getSimulationTime()/(60*1)),(float)(1),255,0,0,iptgV);
		drawAxes((float)(-13),(float)(boundCentre.y+1.05*bound.y/2),(float)boundCentre.z);
		drawCurve((float)(-13),(float)(boundCentre.y+1.05*bound.y/2),(float)boundCentre.z,(float)(bound.x-1.3),(float)(-bound.y/2),(float)(sim.getSimulationTime()/(60*1)),(float)(10),0,250,100,contv);
//		drawCurve((float)(-13),(float)(boundCentre.y+1.05*bound.y/2),(float)boundCentre.z,(float)(bound.x-1.3),(float)(-bound.y/2),(float)(sim.getSimulationTime()/(60*1)),(float)(1),0,20,100,refv);
		
		
		current++;
		
		p3d.fill(0);//I write on screen also the ratio of population that is switched
		 //PER ORA LA AGGIUNGO STATICA E POI LA MODIFICO E LA METTO NELLA FUNZIONE
		p3d.text("t", width/2+((float)1.25*width/4), height/2, 50, 20);
		p3d.text(sim.getSimulationTime()/60+" ",(float) (width-60), height/2, 50, 20); 
		p3d.text("0",(float) (width/2+1.05*width/6+40), height/2, 50, 20);
		p3d.text("0",(float) (width/2+1.05*width/6+20),(float) (height/2-15), 50, 20);
		p3d.text("2000",(float) (width/2+1.05*width/6-5),(float) (40), 50, 20);
		p3d.text(sim.getSimulationTime()/60+" ",(float) (width-60), (float)(height/2-15+height/2), 50, 20); 
		p3d.text("0",(float) (width/2+1.05*width/6+40),(float) (height/2-15+height/2), 50, 20);
		p3d.text("0",(float) (width/2+1.05*width/6+20),(float) (height/2-30+height/2), 50, 20);
		p3d.text("1",(float) (width/2+1.05*width/6-5),(float) (40+0.9*height/2), 50, 20);
		//String mess="Population Rate Switched="+((double)cont/(double)bacteria.size());
		//p3d.text(mess, 50, 70);//And the current population size
		p3d.text("Population size= "+bacteria.size(),50,90);
		p3d.fill(0, 255, 0);
		p3d.text("Lac",(float) (width/2+1.05*width/6), height/4, 50, 20);
		p3d.text("aTc",(float) (width/2+1.02*width/6), (float)(height/4+height/2), 50, 20);
		p3d.fill(255, 0, 0);
		p3d.text("Tet",(float) (width/2+1.05*width/6),(float) (height/4+20), 50, 20);
		p3d.text("IPTG",(float) (width/2+1.02*width/6),(float) (height/4+20+height/2), 50, 20);
		
	}

	@Override
	public void time() {
		p3d.fill(0);
		String t="Time = "+sim.getTime()/60+" min"; //I simply write the time in minutes rather than in seconds
		p3d.text(t, 50, 50);
	}

	
	public void drawAxes(float x,float y, float z) {
		p3d.noFill();
		p3d.stroke(0,0,0);
		p3d.pushMatrix();
		p3d.translate(x,y,z);
		//DISEGNO GLI ASSI
		p3d.line(0,0,(float)(bound.x-1.7),0);
		p3d.line(0,0,0,(float)(-bound.y/2)); //ASSe y invertito ?
		p3d.noStroke();
		p3d.fill(0);
		//DISEGNO LE FRECCETTE DEGLI ASSI
		p3d.triangle((float)(bound.x-1.7),(float) 0.4, (float)(bound.x-1.7),(float) -0.4, (float)(bound.x-1.3), 0);
		p3d.triangle((float)-0.4,(float)(-bound.y/2), (float) 0.4,(float)(-bound.y/2), 0, (float)(-bound.y/2-0.4));
		p3d.popMatrix();
		p3d.noFill();
	}
	
	public void drawCurve(float x,float y, float z,float endx,float endy,float maxx,float maxy,int r,int g, int b,double [] data) {
		p3d.noFill();
		p3d.stroke(r,g,b);
		p3d.pushMatrix();
		p3d.translate(x,y,z);
		p3d.beginShape();
		for(int i=0;i<current;i++) {
			//System.out.println("LavV= "+(-(LacV[i]/maxy)*endy));
			//System.out.println("i="+i+" endx= "+maxx);
			p3d.vertex((float)((i/maxx)*endx),(float)((data[i]/maxy)*endy));
		}
		
		p3d.endShape();
		p3d.popMatrix();
		p3d.noStroke();
	}
	
	
	
	/**
     * Draw the default cuboid boundary of the simulation as a partially transparent box
     * with a wireframe outline surrounding it.
     */
    @Override
    public void boundaries() {
        p3d.noFill();
        p3d.stroke(128, 128, 255);
        p3d.pushMatrix();
        p3d.translate((float)boundCentre.x,(float)boundCentre.y,(float)boundCentre.z);
        p3d.box((float)bound.x, (float)bound.y, (float)bound.z);
        p3d.popMatrix();
        p3d.noStroke();
    }

    //This is to have a visual from the high
    @Override
    public void draw(Graphics2D g) {
        p3d.beginDraw();

        if(!cameraIsInitialised){
            // camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ)
            p3d.camera((float)bound.x*0.5f, (float)bound.y*0.5f,
                    // Set the Z offset to the largest of X/Y dimensions for a reasonable zoom-out distance:
                    simX > simY ? (float)simX : (float)simY,
//                    10,
                    (float)bound.x*0.5f, (float)bound.y*0.5f, 0,
                    0,1,0);
            cameraIsInitialised = true;
        }

        p3d.textFont(font);
        p3d.textMode(PConstants.SCREEN);
        

        p3d.sphereDetail(10);
        p3d.noStroke();
        p3d.background(255, 255,255);

        scene(p3d);
        boundaries();
        time();

        p3d.endDraw();
        g.drawImage(p3d.image, 0,0, null);
    }
	
	

}
