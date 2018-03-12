//
//  Shader.vsh
//  test
//
//  Created by nobuts on 13-1-17.
//  Copyright (c) 2013年 nobuts. All rights reserved.
//

attribute vec4 position; 
attribute vec2 TexCoordIn; 
varying vec2 TexCoordOut; 

void main(void)
{
    gl_Position = position; 
    TexCoordOut = TexCoordIn;
}
