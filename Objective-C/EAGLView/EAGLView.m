//
//  EAGLView.m
//  iControl
//
//  Created by dabao on 12-3-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "EAGLView.h"

@interface EAGLView (Private)

-(void) setupLayer;
-(void) setupContext;
-(void) setupRenderBuffer;
-(void) setupFrameBuffer;
-(void) setupShader;
-(GLuint) createShader:(NSString *)shaderName withType:(GLenum)shaderType;

@end

@implementation EAGLView

#pragma mark - create opengl context

+(Class) layerClass
{
    return [CAEAGLLayer class];
}

-(void) setupLayer
{
    eaglLayer=(CAEAGLLayer*)self.layer;
    eaglLayer.opaque=YES;
}

-(void) setupContext
{
    EAGLRenderingAPI api=kEAGLRenderingAPIOpenGLES2;
    context=[[EAGLContext alloc] initWithAPI:api];
    
    if(!context)
    {
        NSLog(@"Failed to create OpenGLES 2.0 context!");
        exit(1);
    }
    
    if(![EAGLContext setCurrentContext:context])
    {
        NSLog(@"Failed to set current OpenGL context!");
        exit(1);
    }
}

-(void) setupRenderBuffer
{
    glGenRenderbuffers(1, &colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
}

-(void) setupFrameBuffer
{
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self setupShader];
        [self setupVBO];
        [self drawRect:[self bounds]];
    }
    return self;
}


- (void)dealloc
{
    [context release];
    context=nil;
    [super dealloc];
}

#pragma mark - shader

-(GLuint) createShader:(NSString *)shaderName withType:(GLenum)shaderType
{
    NSString *shaderPath=[[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError *error;
    NSString *shaderString=[NSString 
                            stringWithContentsOfFile:shaderPath 
                            encoding:NSUTF8StringEncoding 
                            error:&error];
    if(!shaderString)
    {
        NSLog(@"Error loading shader: %@",error.localizedDescription);
        exit(1);
    }
    
    GLuint shaderHandle=glCreateShader(shaderType);
    
    const char *shaderStringUTF8=[shaderString UTF8String];
    int shaderStringLength=[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if(compileSuccess==GL_FALSE)
    {
        GLchar message[256];
        glGetShaderInfoLog(shaderHandle, sizeof(message), 0, message);
        NSLog(@"%@",[NSString stringWithUTF8String:message]);
        exit(1);
    }
    
    return shaderHandle;
}

-(void) setupShader
{
    GLuint vertexShader=[self createShader:@"vertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader=[self createShader:@"fragment" withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle=glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if(linkSuccess==GL_FALSE)
    {
        GLchar message[256];
        glGetProgramInfoLog(programHandle, sizeof(message), 0, message);
        NSLog(@"%@",[NSString stringWithUTF8String:message]);
        exit(1);
    }
    
    glUseProgram(programHandle);
    
    positionSlot=glGetAttribLocation(programHandle, "Position");
    colorSlot=glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(positionSlot);
    glEnableVertexAttribArray(colorSlot);
}

#pragma mark - render

-(void) prepareRender
{
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
}


typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

-(void) setupVBO
{
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}

-(void) render
{
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)(sizeof(float)*3));
    
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
}

- (void)drawRect:(CGRect)rect
{
    [self prepareRender];
    [self render];
    
    [context presentRenderbuffer:GL_RENDERBUFFER];
}


@end
