package bLogger;

import bsim.BSim;
import bsim.BSimChemicalField;
import bsim.export.BSimLogger;

public class ConcLogger extends BSimLogger {

	private BSimChemicalField field;
	
	public ConcLogger(BSim sim, String filename,BSimChemicalField field) {
		super(sim, filename);
		this.field=field;
		// TODO Auto-generated constructor stub
	}

	@Override
	public void during() {
		
		String buffer=new String();
		// TODO Auto-generated method stub
		for(int i = 0; i < field.getBoxes()[0]; i++){
			for(int j = 0; j < field.getBoxes()[1]; j++){
				for(int z = 0; z < field.getBoxes()[2]; z++){
					buffer+=field.getConc(i, j, z)+",";
				}
			}
		}
		
		write(buffer);
		
		
	}

}
