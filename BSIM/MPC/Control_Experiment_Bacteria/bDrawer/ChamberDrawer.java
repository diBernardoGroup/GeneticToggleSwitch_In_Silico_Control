
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

public class ChamberDrawer extends BSimP3DDrawer {
	//Active Bacteria
	private Vector<BSimControlledBacterium> bacteria;

	//Bounds
	private double simX;
	private double simY;
	

	
	
	public ChamberDrawer(BSim sim, int width, int height,Vector<BSimControlledBacterium> bacteria) {
		super(sim, width, height);
		this.bacteria=bacteria;
		simX=sim.getBound().getX();
		simY=sim.getBound().getY();
		//simZ=sim.getBound().getZ();
		
	}

	@Override
	public void scene(PGraphics3D p3d) {	
		
		p3d.ambientLight(128, 128, 128);
        p3d.directionalLight(128, 128, 128, 1, 1, -1);
		
		
		double thres=10;
		
		
		for(BSimControlledBacterium b : bacteria) { //For each bacterium here
			
			
			int red=0;
			int green=0;
			double rateTL=b.y[2]/b.y[3]; //Lac on TetR
			//Color setting in dependance of The switching
			if(rateTL<=0) {
				red=255;
			}
			else {
				if(rateTL<thres) {
					red=255-(int) Math.floor(((rateTL/thres)*255)); //I set the color in a way taht it is red if it has not writched and green otherwise	
					green=(int) Math.floor(((rateTL/thres)*255));
				}
				else {
					green=255;
				}		
			}
			draw(b, new Color(green,red,0));
		}

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
