//
//  Floor.metal
//  Meadow
//
//  Created by Zack Brown on 06/02/2019.
//  Copyright © 2019 Script Orchard. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include <SceneKit/scn_metal>

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
    float4 gridPosition [[user(gridPosition)]];
};

constant half4 gridColor = half4(half3(0.35), 1.0);
constant half4 floorColor = half4(half3(1.0), 1.0);

vertex FragmentIn floor_vertex(VertexIn v [[ stage_in ]], constant SCNSceneBuffer& scn_frame [[buffer(0)]], constant NodeBuffer& scn_node [[buffer(1)]]) {
    
    FragmentIn f;
    
    float3 vector = float3(-v.position.x, 0.0, v.position.y);
    
    f.position = scn_node.modelViewProjectionTransform * float4(vector, 1.0);
    //f.position = float4(v.position, 1.0);
    f.gridPosition = scn_node.modelTransform * float4(vector, 1.0);
    
    return f;
}

fragment half4 floor_fragment(FragmentIn f [[stage_in]]) {
    
    float2 position = f.gridPosition.xz;
    float2 fractional  = abs(fract(position + 0.5));
    float2 partial = fwidth(position);
    
    float2 point = smoothstep(-partial, partial, fractional);
    
    float saturation = 1.0 - saturate(point.x * point.y);
    
    return half4(mix(gridColor.rgb, floorColor.rgb, saturation), 1.0);
}
