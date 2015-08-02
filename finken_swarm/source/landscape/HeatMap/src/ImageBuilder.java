import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;

import javax.imageio.ImageIO;

public class ImageBuilder {

	public static void main(String[] args) {
		/*
		 * byte[] imageData = new byte[1024*1024*3]; for(int i=0; i<1024; i++){
		 * for(int j=0; j<1024*3; j+=3){ imageData[1024*i +j] = 0;
		 * imageData[1024*i +j+1] = 0; imageData[1024*i +j+2] = 0; } } try {
		 * ByteArrayInputStream bais = new ByteArrayInputStream(imageData);
		 * System.out.println(bais.available()); BufferedImage image =
		 * ImageIO.read(bais); File outputfile = new File("landscape.png");
		 * ImageIO.write(image, "PNG", outputfile); } catch (IOException e) { //
		 * TODO Auto-generated catch block e.printStackTrace(); }
		 */
		mkImage();
	}

	public static void mkImage() {
		BufferedImage image = new BufferedImage(1024, 1024,
				BufferedImage.TYPE_INT_RGB);

		for (int x = 0; x < 1024; x++) {
			for (int y = 0; y < 1024; y++) {
				int value = landscape(x,y);
				int rgb = value;// red
				rgb = (rgb << 8) + value; // green
				rgb = (rgb << 8) + value; // blue
				image.setRGB(x, y, rgb);
			}
		}

		File outputFile = new File("output.bmp");
		try {
			ImageIO.write(image, "bmp", outputFile);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public static int landscape(int x, int y) {
		int value = (int) ((191.0/1024.0*y+64)*Math.exp(-0.000025*(x-512)*(x-512)));
		if(value < 0 || value > 255){
			System.err.println("OUTOFRANGE" + value + "("+x+","+y+")");
		}
		return value;
	}
}
