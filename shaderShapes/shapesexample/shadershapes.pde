class shaderShapes {
  int[] commandType; // what shape or command the shader shall do
  float[] AB; // AB first two verts of shape, OR one color
  float[] CD; // additional verts for some shapes
  int commandIndex;
  PGraphics view;
  PShader glshapes;
  boolean flipY = false; // shader has flipped Y-coordinate compared to proccssing 

  shaderShapes() {
    view = createGraphics(width, height, P2D);
    glshapes = loadShader("shapes.glsl");
    view.shader(glshapes);
  }
  
  void beginDraw(){
   // clear arrays and counters
   commandType = new int[13];
   commandIndex=0;
   AB = new float[4*13];
   CD = new float[4*13];
   }
   void endDraw(){
   //send arrays to, and render them in shader
   glshapes.set("command", commandType);
   glshapes.set("AB", AB, 4);
   glshapes.set("CD", CD, 4);
   view.beginDraw();
   //view.shader(glshapes);
   view.rect(0,0,width,height);
   view.endDraw();
   image(view,0,0);
   }
  
  
  //float flip(float in) {return flipY?(height - in):in;}

  /* lots of setting AB and CD array going on */
  
  void ABCD(float... input){
    for (int i=0; i<input.length;i++){
      int temp = commandIndex*4+i;
      float val = input[i];
      int com = commandType[commandIndex];
      // flip Y coordinates if needed
      if( flipY && com > 0 && com < 6 && i%2 ==1 ){
        
        /* added to not "flip" height of ellipse" */ 
        if( com !=3 || com==3 && i==1){
        val=height-val;
        }
        
      }
      if (i<4){
      AB[temp]=val;
      }
      else if (i<8){
      CD[temp-4]=val;
      }
    }
  }
   void rectMode(int i){
   // does nothing
   }
   void rect(){
   // does nothing
   }
   
   void strokeWeight(float W){}
   
   void ellipse(float X, float Y, float W, float H){
   commandType[commandIndex] = 3;
   ABCD(X,Y,W,H);
   commandIndex++;
   }
   void triangle(float A, float B, float C, float D, float E, float F){
   commandType[commandIndex] = 4;
   ABCD(A,B,C,D,E,F);
   commandIndex++;
   }
   void quad(float A,float B, float C, float D, float E,float F, float G, float H){
   commandType[commandIndex] = 5;
   ABCD(A,B,C,D,E,F,G,H);
   commandIndex++;
   }
   void line(float A,float B, float C, float D){
   commandType[commandIndex]=1;
   ABCD(A,B,C,D);
   commandIndex++;
   }
   
  /* bezier should for performance make lines in this class */
  void bezier(float A, float B, float C, float D, float E, float F, float G, float H) {
    commandType[commandIndex]=2;
    ABCD(A,B,C,D,E,F,G,H);
    commandIndex++;
  }
   
   void fill(color input){
   commandType[commandIndex] = 6;
   addcolor(input);
   commandIndex++;
   }
   void stroke(color input){
   // should work like fill
   commandType[commandIndex] = 7;
   addcolor(input);
   commandIndex++;
   }
   void background(color input){
   commandType[commandIndex] = 9;
   addcolor(input);
   commandIndex++;
   }
   void addcolor(color input){
   float [] vec = rgba2vec4(input);
   ABCD (vec[0],vec[1],vec[1],vec[2]);
   }
   // shall convert rgba int to 4 normalized floats
   // will probably break on other color format?
   float[] rgba2vec4(color input){
   float[] output = new float[4];
   output[0] = ((input >> 16) & 255)/255.;
   output[1] = ((input >>  8) & 255)/255.;
   output[2] = ( input        & 255)/255.;
   output[3] = ((input >> 24) & 255)/255.;
   return output;
   }
}