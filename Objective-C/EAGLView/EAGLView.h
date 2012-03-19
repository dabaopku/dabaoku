//
//  EAGLView.h
//  iControl
//
//  Created by dabao on 12-3-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface EAGLView : UIView {
    
    CAEAGLLayer *eaglLayer;
    EAGLContext *context;
    GLuint colorRenderBuffer;
    GLuint frameBuffer;
    
    CGColorRef backgoundColor;
    
    GLuint positionSlot;
    GLuint colorSlot;
}

-(void) setupVBO;
-(void) prepareRender;
-(void) render;

@end
