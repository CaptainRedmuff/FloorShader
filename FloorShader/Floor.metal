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

constant float epsilon = 0.0001;

struct Plane {
    
    float3 position;
    float3 normal;
};

struct Ray {
    
    float3 origin;
    float3 direction;
};

struct RayHitTest {
    
    float3 vector;
    float distance;
    bool hit;
};

struct NodeBuffer {
    
    float4x4 modelTransform;
    float4x4 modelViewTransform;
    float4x4 normalTransform;
    float4x4 modelViewProjectionTransform;
};

struct Vertex {
    
    float3 position [[ attribute(SCNVertexSemanticPosition) ]];
};

struct Fragment {
    
    float4 position [[position]];
    float2 ij;
    
    float worldFloor;
    
    half4 backgroundColor;
    half4 gridColor;
};

RayHitTest intersect(Plane plane, Ray ray) {
    
    float denominator = dot(plane.normal, ray.direction);
    
    if (fabs(denominator) < epsilon) {
        
        return RayHitTest { .hit = false };
    }
        
    float3 v0 = (plane.position - ray.origin);
    
    float distance = dot(v0, plane.normal) / denominator;
    
    return RayHitTest { .hit = distance > epsilon, .distance = distance, .vector = ray.origin + (ray.direction * distance) };
}

vertex Fragment floor_vertex(Vertex v [[ stage_in ]]) {
    
    Fragment f;
    
    f.position = float4(v.position, 1.0);
    f.ij = v.position.xy;
    f.backgroundColor = half4(0.0, 0.0, 0.0, 1.0);
    f.gridColor = half4(1.0);
    
    return f;
}

fragment half4 floor_fragment(Fragment f [[stage_in]], constant SCNSceneBuffer& scn_frame [[buffer(0)]], constant NodeBuffer& scn_node [[buffer(1)]]) {
    
    //f.ij is in the vertex position in clip space (-1, -1) to (1, 1)
    
    //convert position into camera space
    float4 position = (scn_frame.inverseViewProjectionTransform * float4(f.ij.x, f.ij.y, 0.0, 1.0));

    //create ray from camera with direction
    Ray ray = Ray { .origin = float3(0.0), .direction = normalize(position.xyz) };
    
    //convert floor plane from world space to camera space
    float3 worldFloor = (scn_node.modelViewTransform * float4(float3(0.0, -5.0, 0.0), 1.0)).xyz;
    
    //hit test ray against floor plane
    Plane plane = Plane { .position = worldFloor, .normal = float3(0.0, 1.0, 0.0) };

    RayHitTest hitTest = intersect(plane, ray);

    if(!hitTest.hit) {
        
        return f.backgroundColor;
    }
    
    //grab xz values to determine floor fragment color
    float2 uv = hitTest.vector.xz;
    
    float2 fractional  = abs(fract(uv + 0.5));
    float2 partial = fwidth(uv);
    
    float2 point = smoothstep(-partial, partial, fractional);
    
    float saturation = 1.0 - saturate(point.x * point.y);
    
    return half4(mix(f.backgroundColor.rgb, f.gridColor.rgb, saturation), 1.0);
}
