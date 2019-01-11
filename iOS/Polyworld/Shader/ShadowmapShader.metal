//
//  ShadowmapShader.metal
//  Polyworld
//
//  Created by 沈心逸 on 2019/1/11.
//  Copyright © 2019年 Sxy. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct ShadowmapVertexIn {
    packed_float2 position;
    float triangleType;
};

struct ShadowmapVertexUniform {
    uint scene_size;
    float scalefactor;
    packed_float3 scene_offset; // 6 7 8 empty
    float4x4 PVMatrix; // 9 ~ 24
};

vertex float4 shadowmapVertex(constant ShadowmapVertexIn *vertices [[buffer(0)]],
                              constant float *height [[buffer(1)]],
                              constant ShadowmapVertexUniform &uniforms [[buffer(2)]],
                              uint vid [[vertex_id]],
                              uint iid [[instance_id]])
{
    ShadowmapVertexIn in = vertices[vid];
    
    int idx = iid / uniforms.scene_size, idy = iid % uniforms.scene_size;
    float deltax = idx - uniforms.scene_size / 2.0f, deltay = idy - uniforms.scene_size / 2.0f;
    float3 pos = float3(in.position.x + deltax, 0.0f, in.position.y + deltay) * uniforms.scalefactor;
    
    int index = 0;
    if (vid == 0) index = (idy + 1) * (uniforms.scene_size + 1) + idx + 1;
    else if (vid == 1 || vid == 4) index = idy * (uniforms.scene_size + 1) + idx + 1;
    else if (vid == 2 || vid == 3) index = (idy + 1) * (uniforms.scene_size + 1) + idx;
    else index = idy * (uniforms.scene_size + 1) + idx;
    pos.y = height[index];
    
    pos.y = pos.y * 10.0f;

    return uniforms.PVMatrix * float4(pos + uniforms.scene_offset, 1.0f);
}

fragment float4 shadowmapFragment(float4 vert [[stage_in]])
{
    return float4(0, 0, 0, 1);
}

