float dz=0; // distance to camera. Manipulated with wheel or when 
float rx=-0.06*TWO_PI, ry=-0.04*TWO_PI;    // view angles manipulated when space pressed but not mouse
Boolean twistFree=false, animating=true, center=true, showControlPolygon=true, showFloor=false, curves=true;
float t=0, s=0;
pt F = P(0,0,0);  // focus point:  the camera is looking at it (moved when 'f or 'F' are pressed
pt O=P(100,100,0); // red point controlled by the user via mouseDrag : used for inserting vertices ...
float time=0;
pt[] currentPoints = new pt[12];

void setup() {
  myFace = loadImage("data/pic2.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  size(600, 600, P3D); // p3D means that we will do 3D graphics
  P.declare(); Q.declare(); // P is a polyloop in 3D: declared in pts
  // P.resetOnCircle(12,100); // used to get started if no model exists on file 
  P.loadPts("data/pts");  // loads saved model from file
  Q.loadPts("data/pts2");  // loads saved model from file
  for (int i = 0; i<12; i++){
     currentPoints[i] = P.get(i); 
  }
  }

void draw() {
  background(255);
  pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
    camera();       // sets a standard perspective
    translate(width/2,height/2,dz); // puts origin of model at screen center and moves forward/away by dz
    lights();  // turns on view-dependent lighting
    rotateX(rx); rotateY(ry); // rotates the model around the new origin (center of screen)
    rotateX(PI/2); // rotates frame around X to make X and Y basis vectors parallel to the floor
    if(center) translate(-F.x,-F.y,-F.z);
    noStroke(); // if you use stroke, the weight (width) of it will be scaled with you scaleing factor
    if(showFloor) {
      showFrame(50); // X-red, Y-green, Z-blue arrows
      fill(yellow); pushMatrix(); translate(0,0,-1.5); box(400,400,1); popMatrix(); // draws floor as thin plate
      fill(magenta); show(F,4); // magenta focus point (stays at center of screen)
      fill(magenta,100); showShadow(F,5); // magenta translucent shadow of focus point (after moving it up with 'F'
      if(showControlPolygon) {
        pushMatrix(); 
        fill(grey,100); scale(1,1,0.01); P.drawClosedCurveAsRods(4); 
        P.drawBalls(4); 
        popMatrix();} // show floor shadow of polyloop
      }
    fill(black); show(O,4); fill(red,100); showShadow(O,5); // show red tool point and its shadow

    computeProjectedVectors(); // computes screen projections I, J, K of basis vectors (see bottom of pv3D): used for dragging in viewer's frame 
     
    pp=P.idOfVertexWithClosestScreenProjectionTo(Mouse()); // id of vertex of P with closest screen projection to mouse (us in keyPressed 'x'...

    if(showControlPolygon) {
      if(curves) drawCurves();
      else{
        fill(green); P.drawClosedCurveAsRods(4); P.drawBalls(4); // draw curve P as cones with ball ends
        fill(red); Q.drawClosedCurveAsRods(4); Q.drawBalls(4); // draw curve Q
      }
      fill(green,100); //P.drawBalls(5); // draw semitransluent green balls around the vertices
      fill(grey,100); //show(P.closestProjectionOf(O),6); // compputes and shows the closest projection of O on P
      fill(red,100); P.showPicked(6); // shows currently picked vertex in red (last key action 'x', 'z'
      //stroke(black);
      //show(P.get(0), 15);
      
      
      }
   
    
    if(animating) {
      PtQ.setToL(P,s,Q); 
      //PtQ.drawClosedLoop(); 
      
      getCurrentPoints();
      fill(cyan); 
      //stroke(cyan);
      noStroke();
      //showTB();
      //showBi();
      //showCoons();
      shadeSurface(0.05);
      drawBorders2();
      time+=0.01;
      if(time>1){
         time=0; 
      }
    }
    
  popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas

  if(keyPressed) {stroke(red); fill(white); ellipse(mouseX,mouseY,26,26); fill(red); text(key,mouseX-5,mouseY+4);}
 
    // for demos: shows the mouse and the key pressed (but it may be hidden by the 3D model)
  if(scribeText) {fill(black); displayHeader();} // dispalys header on canvas, including my face
  if(scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
  if (animating) {if(t>=TWO_PI) t=0; s=(cos(t)+1.)/2; t+=PI/180; } // periodic change of time 
  if(filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++,4)+".tif");  // save next frame to make a movie
  change=false; // to avoid capturing frames when nothing happens (change is set uppn action)
  uvShow(); //**<01
  
  
  
  //System.out.print("frame");
  }
  
void keyPressed() {
  if(key=='?') scribeText=!scribeText;
  if(key=='!') snapPicture();
  if(key=='~') filming=!filming;
  if(key==']') showControlPolygon=!showControlPolygon;
  if(key=='0') P.flatten();
  if(key=='_') showFloor=!showFloor;
  if(key=='q') Q.copyFrom(P);
  if(key=='p') P.copyFrom(Q);
  if(key=='e') {PtQ.copyFrom(Q);Q.copyFrom(P);P.copyFrom(PtQ);}
  if(key=='.') F=P.Picked(); // snaps focus F to the selected vertex of P (easier to rotate and zoom while keeping it in center)
  if(key=='x' || key=='z' || key=='d') P.setPickedTo(pp); // picks the vertex of P that has closest projeciton to mouse
  if(key=='d') P.deletePicked();
  if(key=='i') P.insertClosestProjection(O); // Inserts new vertex in P that is the closeset projection of O
  if(key=='W') {P.savePts("data/pts"); Q.savePts("data/pts2");}  // save vertices to pts2
  if(key=='L') {P.loadPts("data/pts"); Q.loadPts("data/pts2");}   // loads saved model
  if(key=='w') P.savePts("data/pts");   // save vertices to pts
  if(key=='l') P.loadPts("data/pts"); 
  if(key=='a'){ animating=!animating; time=0;}// toggle animation
  if(key=='#') exit();
  if(key=='c') curves = !curves;
  change=true;
  }

void mouseWheel(MouseEvent event) {dz -= event.getAmount(); change=true;}

void mouseMoved() {
  if (keyPressed && key==' ') {rx-=PI*(mouseY-pmouseY)/height; ry+=PI*(mouseX-pmouseX)/width;};
  if (keyPressed && key=='s') dz+=(float)(mouseY-pmouseY); // approach view (same as wheel)
  if (keyPressed && key=='v') { //**<01 
      u+=(float)(mouseX-pmouseX)/width;  u=max(min(u,1),0);
      v+=(float)(mouseY-pmouseY)/height; v=max(min(v,1),0); 
      } 
  }
void mouseDragged() {
  if (!keyPressed) {O.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); }
  if (keyPressed && key==CODED && keyCode==SHIFT) {O.add(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0)));};
  if (keyPressed && key=='x') P.movePicked(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='z') P.movePicked(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='X') P.moveAll(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='Z') P.moveAll(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='f') { // move focus point on plane
    if(center) F.sub(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    else F.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    }
  if (keyPressed && key=='F') { // move focus point vertically
    if(center) F.sub(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    else F.add(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    }
  }
  
void drawCurves(){
   for (float t = 0; t<=1; t+=0.001) {
     //System.out.print(t + ",");
       stroke(green);
       strokeWeight(3);
       pt T = neville(P.get(0), P.get(1), P.get(2), P.get(3), t);
       //show(T, 2);
       
       point(T.x,T.y,T.z);
       pt B = neville(P.get(9), P.get(8), P.get(7), P.get(6), t);
       //show(B, 2);
       point(B.x,B.y,B.z);
       //stroke(yellow);
       pt L = neville(P.get(9), P.get(10), P.get(11), P.get(0), t);
       //show(L, 2);
       point(L.x,L.y,L.z);
       pt R = neville(P.get(6), P.get(5), P.get(4), P.get(3), t);
       //show(R, 2);
       point(R.x,R.y,R.z);
       stroke(red);
       pt T2 = neville(Q.get(0), Q.get(1), Q.get(2), Q.get(3), t);
       //show(T2, 2);
       point(T2.x,T2.y,T2.z);
       pt B2 = neville(Q.get(9), Q.get(8), Q.get(7), Q.get(6), t);
       //show(B2, 2);
       point(B2.x,B2.y,B2.z);
       pt L2 = neville(Q.get(9), Q.get(10), Q.get(11), Q.get(0), t);
       //show(L2, 2);
       point(L2.x,L2.y,L2.z);
       pt R2 = neville(Q.get(6), Q.get(5), Q.get(4), Q.get(3), t);
       //show(R2, 2);
       point(R2.x,R2.y,R2.z);
   }
}

pt neville(pt A1, pt A2, pt A3, pt A4, float t){
    float a = 0, b = (float)1/3, c = (float)2/3, d = 1;
    pt L_AB = L(a, A1, b, A2, t);
    pt L_BC = L(b, A2, c, A3, t);
    pt L_CD = L(c, A3, d, A4, t);
    
    pt L_ABC = L(a, L_AB, c, L_BC, t);
    pt L_BCD = L(b, L_BC, d, L_CD, t);
    
    pt L_ABCD = L(a, L_ABC, d, L_BCD, t);
    //System.out.print(L_ABCD.x + ", ");
    return L_ABCD;
  }  
  
void showLR(){
  stroke(red);
   for(float t = 0; t <=1; t+=0.01){
      for(float s = 0; s <= 1; s += 0.01){
         pt LR = L(neville(P.get(9), P.get(10), P.get(11), P.get(0), s), t, neville(P.get(6), P.get(5), P.get(4), P.get(3), s));
         point(LR.x, LR.y, LR.z);
      } 
   }
}
void showTB(){
  stroke(red);
   for(float t = 0; t <=1; t+=0.01){
      for(float s = 0; s <= 1; s += 0.01){
         pt TB = L(neville(P.get(0), P.get(1), P.get(2), P.get(3), s), t, neville(P.get(9), P.get(8), P.get(7), P.get(6), s));
         point(TB.x, TB.y, TB.z);
      } 
   }
}

void showBi(){
    
    stroke(red);
   for(float t = 0; t <=1; t+=0.01){
      for(float s = 0; s <= 1; s += 0.01){
         pt Bi = bilinear(P.get(9), P.get(0), P.get(6), P.get(3), s, t);
         point(Bi.x, Bi.y, Bi.z);
      } 
   }
}
  
void getCurrentPoints(){
   for(int i = 0; i<12; i++){
      currentPoints[i] = L(P.get(i), time, Q.get(i));
      stroke(black); strokeWeight(5);
      point(currentPoints[i].x, currentPoints[i].y, currentPoints[i].z);
   } 
}
  
void drawBorders(){   
     /*for(float s = 0; s<=1; s+= 0.001){
        stroke(blue);
       strokeWeight(2);
       pt T1 = neville(P.get(0), P.get(1), P.get(2), P.get(3), s);
       pt B1 = neville(P.get(9), P.get(8), P.get(7), P.get(6), s);
       pt L1 = neville(P.get(9), P.get(10), P.get(11), P.get(0), s);
       pt R1 = neville(P.get(6), P.get(5), P.get(4), P.get(3), s);
       pt T2 = neville(Q.get(0), Q.get(1), Q.get(2), Q.get(3), s);
       pt B2 = neville(Q.get(9), Q.get(8), Q.get(7), Q.get(6), s);
       pt L2 = neville(Q.get(9), Q.get(10), Q.get(11), Q.get(0), s);
       pt R2 = neville(Q.get(6), Q.get(5), Q.get(4), Q.get(3), s);
       
       pt Tt = L(T1, time, T2);
       point(Tt.x, Tt.y, Tt.z);
       pt Bt = L(B1, time, B2);
       point(Bt.x, Bt.y, Bt.z);
       pt Lt = L(L1, time, L2);
       point(Lt.x, Lt.y, Lt.z);
       pt Rt = L(R1, time, R2);
       point(Rt.x, Rt.y, Rt.z);
     } */
}

void drawBorders2(){
   for(float s = 0; s<=1; s+= 0.001){
    stroke(blue);
    strokeWeight(2);
    pt Ts = Top(s);
    pt Bs = Bottom(s);
    pt Ls = Left(s);
    pt Rs = Right(s); 
    point(Ts.x, Ts.y, Ts.z);
    point(Bs.x, Bs.y, Bs.z);
    point(Ls.x, Ls.y, Ls.z);
    point(Rs.x, Rs.y, Rs.z);
   } 
}

pt Top(float s){return neville(currentPoints[0], currentPoints[1], currentPoints[2], currentPoints[3], s);}
pt Bottom(float s){return neville(currentPoints[9], currentPoints[8], currentPoints[7], currentPoints[6], s);}
pt Left(float s){return neville(currentPoints[9], currentPoints[10], currentPoints[11], currentPoints[0], s);}
pt Right(float s){return neville(currentPoints[6], currentPoints[5], currentPoints[4], currentPoints[3], s);}
  
pt bilinear(pt A, pt B, pt C, pt D, float s, float t){
      return L(L(A, s, B), t, L(C, s, D));
}

pt coons(float s, float t){
    /*pt LR = L(neville(points[9], points[10], points[11], points[0], s), t, neville(points[6], points[5], points[4], points[3], s));
    pt TB = L(neville(points[0], points[1], points[2], points[3], t), s, neville(points[9], points[8], points[7], points[6], t));
    pt Bi = bilinear(points[9], points[0], points[6], points[3], s, t);
    return( new pt(((LR.x+TB.x)-Bi.x),((LR.y+TB.y)-Bi.y),((LR.z+TB.z)-Bi.z)));*/
    pt LR = L(Left(s), t, Right(s));
         pt TB = L(Bottom(t), s, Top(t));
         //pt Bi = bilinear(P.get(9), P.get(0), P.get(6), P.get(3), s, t);
         pt Bi = bilinear(currentPoints[9], currentPoints[0], currentPoints[6], currentPoints[3], s,t); 
         float x = LR.x + TB.x - Bi.x;
         float y = LR.y + TB.y - Bi.y;
         float z = LR.z + TB.z - Bi.z;
         return new pt(x,y,z);
}

void showCoons(){
   stroke(red);
   for(float t = 0; t <=1; t+=0.01){
      for(float s = 0; s <= 1; s += 0.01){
         pt LR = L(Left(s), t, Right(s));
         pt TB = L(Bottom(t), s, Top(t));
         pt Bi = bilinear(P.get(9), P.get(0), P.get(6), P.get(3), s, t);
         float x = LR.x + TB.x - Bi.x;
         float y = LR.y + TB.y - Bi.y;
         float z = LR.z + TB.z - Bi.z;
         point(x, y, z);
      } 
   }
}
  
void shadeSurface(float e){ 
  for(float s=0; s<=1.01-e; s+=e) for(float t=0; t<=1.01-e; t+=e) 
  {beginShape(); v(coons(s,t)); v(coons(s+e,t)); v(coons(s+e,t+e)); v(coons(s,t+e)); endShape(CLOSE);}
  //stroke(blue);
  //point(coons(P, s, t).x, coons(P, s, t).y, coons(P, s, t).z);
  }

// **** Header, footer, help text on canvas
void displayHeader() { // Displays title and authors face on screen
    scribeHeader(title,0); scribeHeaderRight(name); 
    fill(white); image(myFace, width-myFace.width/2,25,myFace.width/2,myFace.height/2); 
    }
void displayFooter() { // Displays help text at the bottom
    scribeFooter(moreGuide, 2);
    scribeFooter(guide,1); 
    scribeFooter(menu,0); 
    }

String title ="2014: Coons patch editor & animator in 3D", name ="Audrey Nelson",
       menu="?:hlp, !:pic, ~:film, SPC:rot, s/whl:zoom, f/F:focus, .:on-pick, drag/shift:red, a:anim, _:floor, #:quit",
       guide="x/z:pick+drag, d:del, i:ins near red, p/q:cpy, e:swap, X/Z:transl, 0:flat, ]:tube, l/L:load, w/W:wrt", // user's guide
       moreGuide="c:switch control polygon";


