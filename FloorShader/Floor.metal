//
//  Floor.metal
//  FloorShader
//
//  Created by Zack Brown on 05/05/2020.
//  Copyright © 2020 Zack Brown. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include <SceneKit/scn_metal>

/*
 
 Available SceneBuffer transforms
 
struct SCNSceneBuffer {
    float4x4    viewTransform;
    float4x4    inverseViewTransform;
    float4x4    projectionTransform;
    float4x4    viewProjectionTransform;
}*/

/*
 
 Available NodeBuffer transforms
 
 */
struct NodeBuffer {
    
    float4x4 modelTransform;
    float4x4 inverseModelTransform;
    float4x4 modelViewTransform;
    float4x4 inverseModelViewTransform;
    float4x4 normalTransform;
    float4x4 modelViewProjectionTransform;
    float4x4 inverseModelViewProjectionTransform;
};

typedef struct {
    
    float3 position [[ attribute(SCNVertexSemanticPosition) ]];
    
} VertexIn;

struct FragmentIn {
    
    float4 position [[position]];
    float2 coordinate [[user(coordinate)]];
};

constant half4 gridColor = half4(half3(0.35), 1.0);
constant half4 floorColor = half4(half3(1.0), 1.0);

vertex FragmentIn floor_vertex(VertexIn v [[ stage_in ]], constant SCNSceneBuffer& scn_frame [[buffer(0)]], constant NodeBuffer& scn_node [[buffer(1)]]) {
    
    FragmentIn f;
    
    f.position = float4(v.position, 1.0);
    f.coordinate = (scn_node.inverseModelViewProjectionTransform * float4(v.position, 1.0)).xy;
    
    return f;
}

fragment half4 floor_fragment(FragmentIn f [[stage_in]]) {
    
    float2 fractional  = abs(fract(f.coordinate - 0.5) - 0.5);
    float2 partial = fwidth(f.coordinate);
    
    float2 g = smoothstep(-partial, partial, fractional);
    
    float grid = 1.0 - saturate(g.x * g.y);
    
    return half4(mix(gridColor.rgb, floorColor.rgb, grid), 1.0);
}
