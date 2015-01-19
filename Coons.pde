/******** Editor of an Animated Coons Patch

Implementation steps:
**<01 Manual control of (u,v) parameters. 
**<02 Draw 4 boundary curves CT(u), CB(u), SL(v), CR(v) using proportional Neville
**<03 Compute and show Coons point C(u,v)
**<04 Display quads filed one-by-one for the animated Coons patch
**<05 Compute and show normal at C(u,v) and a ball ON the patch

*/
//**<01: mouseMoved; 'v', draw: uvShow()
float u=0, v=0; 
void uvShow() { 
  fill(red);
  if(keyPressed && key=='v')  text("u="+u+", v="+v,10,30);
  noStroke(); fill(blue); ellipse(u*width,v*height,5,5); 
  }

