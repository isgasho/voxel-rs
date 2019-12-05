#version 450

layout(location = 0) in vec3 a_Pos;
layout(location = 1) in uint a_Info;

layout(set = 0, binding = 0) uniform Temp1 { mat4 u_ViewProj; };
layout(set = 0, binding = 1) uniform Temp2 { mat4 u_Model; };

layout(location = 0) out vec3 v_Norm;
layout(location = 1) out float occl;
layout(location = 2) out vec3 v_Rgb;


vec3 get_normal(uint id) {
    if(id == 0u) {
        return vec3(1.0, 0.0, 0.0);
    } else if(id == 1u) {
        return vec3(-1.0, 0.0, 0.0);
    } else if(id == 2u) {
        return vec3(0.0, 1.0, 0.0);
    } else if(id == 3u) {
        return vec3(0.0, -1.0, 0.0);
    } else if(id == 4u) {
        return vec3(0.0, 0.0, 1.0);
    } else {
        return vec3(0.0, 0.0, -1.0);
    }
}

vec3 srgbEncode(vec3 color){
    float r = color.r < 0.0031308 ? 12.92 * color.r : 1.055 * pow(color.r, 1.0/2.4) - 0.055;
    float g = color.g < 0.0031308 ? 12.92 * color.g : 1.055 * pow(color.g, 1.0/2.4) - 0.055;
    float b = color.b < 0.0031308 ? 12.92 * color.b : 1.055 * pow(color.b, 1.0/2.4) - 0.055;
    return vec3(r, g, b);
}

vec3 srgbDecode(vec3 color){
    float r = color.r < 0.04045 ? (1.0 / 12.92) * color.r : pow((color.r + 0.055) * (1.0 / 1.055), 2.4);
    float g = color.g < 0.04045 ? (1.0 / 12.92) * color.g : pow((color.g + 0.055) * (1.0 / 1.055), 2.4);
    float b = color.b < 0.04045 ? (1.0 / 12.92) * color.b : pow((color.b + 0.055) * (1.0 / 1.055), 2.4);
    return vec3(r, g, b);
}

void main() {
    gl_Position = u_ViewProj * u_Model * vec4(a_Pos, 1.0);

    uint b = (a_Info & 0x00ff0000u) >> 16u;
    uint g = (a_Info & 0x0000ff00u) >> 8u;
    uint r = a_Info & 0x000000ffu;
    uint code_occl = a_Info >> 27u;
    uint normal = ((a_Info - (code_occl << 27u)) >> 24u);


    if(code_occl == 3u){
        occl = 1.0;
    }else if(code_occl == 2u){
        occl = 0.65;
    }else if(code_occl == 1u){
        occl = 0.4;
    }else{
        occl = 0.3;
    }

    v_Norm = get_normal(normal);

    float rr = float(r)/255.0;
    float gg = float(g)/255.0;
    float bb = float(b)/255.0;

    v_Rgb = srgbDecode(vec3(rr,gg,bb));

}