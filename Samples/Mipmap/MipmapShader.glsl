//------------------------------------------------------------------------------
//  shaders for mipmap-sapp sample
//------------------------------------------------------------------------------
@vs vs
uniform vs_params {
    mat4 mvp;
};

in vec4 pos;
in vec2 uv0;

out vec2 uv;

void main() {
    gl_Position = mvp * pos;
    uv = uv0;
}
@end

@fs fs
uniform sampler2D tex;
in vec2 uv;
out vec4 frag_color;

void main() {
    frag_color = texture(tex, uv);
}
@end

@program mipmap vs fs

