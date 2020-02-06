package bLogger;

import java.util.Vector;

import bBacterium.BSimControlledBacterium;
import bsim.BSim;
import bsim.export.BSimLogger;

public class PopulationLogger extends BSimLogger {
	
	private Vector<BSimControlledBacterium> bacteria;

	public PopulationLogger(BSim sim, String filename, Vector<BSimControlledBacterium> bacteria) {
		super(sim, filename);
		this.bacteria=bacteria;
	}

	@Override
	public void during() {
		double hRatio=0;
		double lRatio=0;
		double lim=2;
		for(BSimControlledBacterium b : bacteria) {
			if(b.y[2]>(lim*b.y[3])) {
				hRatio=hRatio+1;
			}
			if(b.y[3]>(lim*b.y[2])) {
				lRatio=lRatio+1;
			}
		}
		hRatio=hRatio/bacteria.size();
		lRatio=lRatio/bacteria.size();
		write(hRatio+","+lRatio+" ");
	}

}
