/*
    Generate output header in Delphi for sokol_gfx.h
*/
#include "sokoldelphi.h"
#include "fmt/format.h"
#include "pystring.h"
#include <stdio.h>
#include <filesystem>

namespace shdc::gen {

using namespace refl;

static const char* sokol_define(Slang::Enum slang) {
    switch (slang) {
        case Slang::GLSL410:
        case Slang::GLSL430:
            return "SOKOL_GLCORE";
        case Slang::GLSL300ES:
        case Slang::GLSL310ES:
            return "SOKOL_GLES3";
        case Slang::HLSL4:
        case Slang::HLSL5:
            return "SOKOL_D3D11";
        case Slang::METAL_MACOS:
        case Slang::METAL_IOS:
        case Slang::METAL_SIM:
            return "SOKOL_METAL";
        case Slang::WGSL:
            return "SOKOL_WGPU";
        case Slang::SPIRV_VK:
            return "SOKOL_VULKAN";
        default:
            return "<INVALID>";
    }
}

std::string delphi_case(const std::string str)
{
    if (str.length() == 2)
        return pystring::upper(str);
    else
        return pystring::capitalize(str);
}

ErrMsg SokolDelphiGenerator::begin(const GenInput& gen) {
    tab_width = 2;
    if (!gen.inp.module.empty()) {
        mod_prefix = fmt::format("{}_", gen.inp.module);
    }
    if (gen.args.output_format != Format::SOKOL_IMPL) {
        func_prefix = "static inline ";
    }
    return Generator::begin(gen);
}

void SokolDelphiGenerator::gen_prolog(const GenInput& gen) {
    auto unit = gen.args.output;
    std::filesystem::path p(unit);
    std::filesystem::path ext("");
    unit = p.replace_extension(ext).filename().string();

    l("unit {};\n", unit);
}

void SokolDelphiGenerator::gen_epilog(const GenInput& gen) {
    l("\nend.\n");

    // Convert C-style Hex values (0x) to Delphi ($)
    content = pystring::replace(content, "0x", "$");

    // Convert ",);" at end of arrays with ");"
    content = pystring::replace(content, ",);", ");");
}

void SokolDelphiGenerator::gen_prerequisites(const GenInput& gen) {
    l("\n{{$INCLUDE 'Neslib.Sokol.inc'}}\n\n");
    l("interface\n\n");
    l("uses\n");
    l("  Neslib.FastMath,\n");
    l("  Neslib.Sokol.Gfx;\n\n");
}

void SokolDelphiGenerator::gen_vertex_attr_consts(const GenInput& gen) {
    l("const\n");
    Generator::gen_vertex_attr_consts(gen);
    l("\n");
}

void SokolDelphiGenerator::gen_bind_slot_consts(const GenInput& gen) {
    l("const\n");
    Generator::gen_bind_slot_consts(gen);
    l("\n");
}

void SokolDelphiGenerator::gen_uniform_block_decl(const GenInput &gen, const UniformBlock& ub) {
    l_open("type\n");
    l("{} = packed record\n", struct_name(ub.name));
    l_open("public\n");

    int cur_offset = 0;
    for (const Type& uniform: ub.struct_info.struct_items) {
        int next_offset = uniform.offset;
        if (next_offset > cur_offset) {
            l("_Pad{}: array [0..{}] of Byte;\n", cur_offset, next_offset - cur_offset - 1);
            cur_offset = next_offset;
        }
        auto uniform_name = delphi_case(uniform.name);
        if (gen.inp.ctype_map.count(uniform.type_as_glsl()) > 0) {
            // user-provided type names
            if (uniform.array_count == 0) {
                l("{}: {};\n", uniform_name, gen.inp.ctype_map.at(uniform.type_as_glsl()));
            } else {
                l("{}: array [0..{}] of {};\n", uniform_name, uniform.array_count - 1, gen.inp.ctype_map.at(uniform.type_as_glsl()));
            }
        } else {
            // default type names (float)
            if (uniform.array_count == 0) {
                switch (uniform.type) {
                    case Type::Float:   l("{}: Single;\n", uniform_name); break;
                    case Type::Float2:  l("{}: TVector2;\n", uniform_name); break;
                    case Type::Float3:  l("{}: TVector3;\n", uniform_name); break;
                    case Type::Float4:  l("{}: TVector4;\n", uniform_name); break;
                    case Type::Int:     l("{}: Integer;\n", uniform_name); break;
                    case Type::Int2:    l("{}: TIVector2;\n", uniform_name); break;
                    case Type::Int3:    l("{}: TIVector3;\n", uniform_name); break;
                    case Type::Int4:    l("{}: TIVector4;\n", uniform_name); break;
                    case Type::Mat4x4:  l("{}: TMatrix4;\n", uniform_name); break;
                    default:            l("INVALID_UNIFORM_TYPE;\n"); break;
                }
            } else {
                switch (uniform.type) {
                    case Type::Float4:  l("{}: array [0..{}] of TVector4;\n", uniform_name, uniform.array_count - 1); break;
                    case Type::Int4:    l("{}: array [0..{}] of TIVector4;\n",   uniform_name, uniform.array_count - 1); break;
                    case Type::Mat4x4:  l("{}: array [0..{}] of TMatrix4; \n", uniform_name, uniform.array_count); break;
                    default:            l("INVALID_UNIFORM_TYPE;\n"); break;
                }
            }
        }
        cur_offset += uniform.size;
    }
    // pad to multiple of 16-bytes struct size
    const int round16 = roundup(cur_offset, 16);
    if (cur_offset < round16) {
        l("_Pad{}: array [0..{}] of Byte;\n", cur_offset, round16 - cur_offset - 1);
    }
    l_close("end align {};\n\n", ub.struct_info.align);
    l_close();
}

void SokolDelphiGenerator::gen_struct_interior_decl_std430(const GenInput& gen, const Type& struc, int pad_to_size) {
    assert(struc.type == Type::Struct);
    assert(pad_to_size > 0);

    int cur_offset = 0;
    for (const Type& item: struc.struct_items) {
        int next_offset = item.offset;
        if (next_offset > cur_offset) {
            l("uint8_t _pad_{}[{}];\n", cur_offset, next_offset - cur_offset);
            cur_offset = next_offset;
        }
        if (item.type == Type::Struct) {
            // recurse into nested struct
            l_open("struct {{\n");
            gen_struct_interior_decl_std430(gen, item, item.size);
            if (item.array_count == 0) {
                // FIXME: do we need any padding here if array_stride != struct-size?
                // NOTE: unbounded arrays are written as regular items
                l_close("}} {};\n", item.name);
            } else {
                l_close("}} {}[{}];\n", item.name, item.array_count);
            }
        } else if (gen.inp.ctype_map.count(item.type_as_glsl()) > 0) {
            // user-mapped typename
            if (item.array_count == 0) {
                l("{} {};\n", gen.inp.ctype_map.at(item.type_as_glsl()), item.name);
            } else {
                l("{} {}[{}];\n", gen.inp.ctype_map.at(item.type_as_glsl()), item.name, item.array_count);
            }
        } else {
            // default typenames
            if (item.array_count == 0) {
                switch (item.type) {
                    // NOTE: bool => int is not a bug!
                    case Type::Bool:    l("int32_t {};\n", item.name); break;
                    case Type::Bool2:   l("int32_t {}[2];\n", item.name); break;
                    case Type::Bool3:   l("int32_t {}[3];\n", item.name); break;
                    case Type::Bool4:   l("int32_t {}[4];\n", item.name); break;
                    case Type::Int:     l("int32_t {};\n", item.name); break;
                    case Type::Int2:    l("int32_t {}[2];\n", item.name); break;
                    case Type::Int3:    l("int32_t {}[3];\n", item.name); break;
                    case Type::Int4:    l("int32_t {}[4];\n", item.name); break;
                    case Type::UInt:    l("uint32_t {};\n", item.name); break;
                    case Type::UInt2:   l("uint32_t {}[2];\n", item.name); break;
                    case Type::UInt3:   l("uint32_t {}[3];\n", item.name); break;
                    case Type::UInt4:   l("uint32_t {}[4];\n", item.name); break;
                    case Type::Float:   l("float {};\n", item.name); break;
                    case Type::Float2:  l("float {}[2];\n", item.name); break;
                    case Type::Float3:  l("float {}[3];\n", item.name); break;
                    case Type::Float4:  l("float {}[4];\n", item.name); break;
                    case Type::Mat2x1:  l("float {}[2];\n", item.name); break;
                    case Type::Mat2x2:  l("float {}[4];\n", item.name); break;
                    case Type::Mat2x3:  l("float {}[6];\n", item.name); break;
                    case Type::Mat2x4:  l("float {}[8];\n", item.name); break;
                    case Type::Mat3x1:  l("float {}[3];\n", item.name); break;
                    case Type::Mat3x2:  l("float {}[6];\n", item.name); break;
                    case Type::Mat3x3:  l("float {}[9];\n", item.name); break;
                    case Type::Mat3x4:  l("float {}[12];\n", item.name); break;
                    case Type::Mat4x1:  l("float {}[4];\n", item.name); break;
                    case Type::Mat4x2:  l("float {}[8];\n", item.name); break;
                    case Type::Mat4x3:  l("float {}[12];\n", item.name); break;
                    case Type::Mat4x4:  l("float {}[16];\n", item.name); break;
                    default: l("INVALID_TYPE\n"); break;
                }
            } else {
                switch (item.type) {
                    // NOTE: bool => int is not a bug!
                    case Type::Bool:    l("int32_t {}[{}];\n", item.name, item.array_count); break;
                    case Type::Bool2:   l("int32_t {}[{}][2];\n", item.name, item.array_count); break;
                    case Type::Bool3:   l("int32_t {}[{}][3];\n", item.name, item.array_count); break;
                    case Type::Bool4:   l("int32_t {}[{}][4];\n", item.name, item.array_count); break;
                    case Type::Int:     l("int32_t {}[{}];\n", item.name, item.array_count); break;
                    case Type::Int2:    l("int32_t {}[{}][2];\n", item.name, item.array_count); break;
                    case Type::Int3:    l("int32_t {}[{}][3];\n", item.name, item.array_count); break;
                    case Type::Int4:    l("int32_t {}[{}][4];\n", item.name, item.array_count); break;
                    case Type::UInt:    l("uint32_t {}[{}];\n", item.name, item.array_count); break;
                    case Type::UInt2:   l("uint32_t {}[{}][2];\n", item.name, item.array_count); break;
                    case Type::UInt3:   l("uint32_t {}[{}][3];\n", item.name, item.array_count); break;
                    case Type::UInt4:   l("uint32_t {}[{}][4];\n", item.name, item.array_count); break;
                    case Type::Float:   l("float {}[{}];\n", item.name, item.array_count); break;
                    case Type::Float2:  l("float {}[{}][2];\n", item.name, item.array_count); break;
                    case Type::Float3:  l("float {}[{}][3];\n", item.name, item.array_count); break;
                    case Type::Float4:  l("float {}[{}][4];\n", item.name, item.array_count); break;
                    case Type::Mat2x1:  l("float {}[{}][2];\n", item.name, item.array_count); break;
                    case Type::Mat2x2:  l("float {}[{}][4];\n", item.name, item.array_count); break;
                    case Type::Mat2x3:  l("float {}[{}][6];\n", item.name, item.array_count); break;
                    case Type::Mat2x4:  l("float {}[{}][8];\n", item.name, item.array_count); break;
                    case Type::Mat3x1:  l("float {}[{}][3];\n", item.name, item.array_count); break;
                    case Type::Mat3x2:  l("float {}[{}][6];\n", item.name, item.array_count); break;
                    case Type::Mat3x3:  l("float {}[{}][9];\n", item.name, item.array_count); break;
                    case Type::Mat3x4:  l("float {}[{}][12];\n", item.name, item.array_count); break;
                    case Type::Mat4x1:  l("float {}[{}][4];\n", item.name, item.array_count); break;
                    case Type::Mat4x2:  l("float {}[{}][8];\n", item.name, item.array_count); break;
                    case Type::Mat4x3:  l("float {}[{}][12];\n", item.name, item.array_count); break;
                    case Type::Mat4x4:  l("float {}[{}][16];\n", item.name, item.array_count); break;
                    default: l("INVALID_TYPE\n"); break;
                }
            }
        }
        cur_offset += item.size;
    }
    if (cur_offset < pad_to_size) {
        l("uint8_t _pad_{}[{}];\n", cur_offset, pad_to_size - cur_offset);
    }
}

void SokolDelphiGenerator::gen_storage_buffer_decl(const GenInput& gen, const Type& struc) {
    l("#pragma pack(push,1)\n");
    l_open("SOKOL_SHDC_ALIGN({}) typedef struct {} {{\n", struc.align, struct_name(struc.struct_typename));
    gen_struct_interior_decl_std430(gen, struc, struc.size);
    l_close("}} {};\n", struct_name(struc.struct_typename));
    l("#pragma pack(pop)\n");
}

void SokolDelphiGenerator::gen_shader_desc_func_prototype(const ProgramReflection& prog) {
    l("function {}ShaderDesc: PNativeShaderDesc;\n", delphi_case(prog.name));
}

void SokolDelphiGenerator::gen_shader_desc_func(const GenInput& gen, const ProgramReflection& prog) {
    std::string prog_name = delphi_case(prog.name);
    std::string desc = fmt::format("G{}ShaderDesc", prog_name);
    l("var\n");
    l("  {}: TNativeShaderDesc;\n\n", desc);

    l("procedure Init{}ShaderDesc;\n", prog_name);
    l_open("begin\n");
    l("{}.Init;\n", desc);

    for (int i = 0; i < Slang::Num; i++) {
        Slang::Enum slang = Slang::from_index(i);
        if (gen.args.slang & Slang::bit(slang)) {
            l("\n");
            if (gen.args.ifdef) {
                l("{{$IFDEF {}}}\n", sokol_define(slang));
            }
            l("if (TGfx.Backend = {}) then\n", backend(slang));
            l_open("begin\n");
            for (int stage_index = 0; stage_index < ShaderStage::Num; stage_index++) {
                const ShaderStageArrayInfo& info = shader_stage_array_info(gen, prog, ShaderStage::from_index(stage_index), slang);
                if (info.stage == ShaderStage::Invalid) {
                    continue;
                }
                const StageReflection& refl = prog.stages[stage_index];
                std::string dsn;
                switch (info.stage) {
                    case ShaderStage::Vertex: dsn = fmt::format("{}.vertex_func", desc); break;
                    case ShaderStage::Fragment: dsn = fmt::format("{}.fragment_func", desc); break;
                    case ShaderStage::Compute: dsn = fmt::format("{}.compute_func", desc); break;
                    default: dsn = "INVALID"; break;
                }
                if (info.has_bytecode) {
                    l("{}.bytecode.ptr := @{};\n", dsn, pystring::upper(info.bytecode_array_name));
                    l("{}.bytecode.size := {};\n", dsn, info.bytecode_array_size);
                } else {
                    l("{}.source := @{};\n", dsn, pystring::upper(info.source_array_name));
                    const char* d3d11_tgt = hlsl_target(slang, info.stage);
                    if (d3d11_tgt) {
                        l("{}.d3d11_target := '{}';\n", dsn, d3d11_tgt);
                    }
                }
                l("{}.entry := '{}';\n", dsn, refl.entry_point_by_slang(slang));
            }
            if (Slang::is_msl(slang) && prog.has_cs()) {
                l("{}.mtl_threads_per_threadgroup.x := {};\n", desc, prog.cs().cs_workgroup_size[0]);
                l("{}.mtl_threads_per_threadgroup.y := {};\n", desc, prog.cs().cs_workgroup_size[1]);
                l("{}.mtl_threads_per_threadgroup.z := {};\n", desc, prog.cs().cs_workgroup_size[2]);
            }
            if (prog.has_vs()) {
                for (int attr_index = 0; attr_index < StageAttr::Num; attr_index++) {
                    const StageAttr& attr = prog.vs().inputs[attr_index];
                    if (attr.slot >= 0) {
                        l("{}.attrs[{}].base_type := {};\n", desc, attr_index, attr_basetype(attr.type_info.basetype()));
                        if (Slang::is_glsl(slang)) {
                            l("{}.attrs[{}].glsl_name := '{}';\n", desc, attr_index, attr.name);
                        } else if (Slang::is_hlsl(slang)) {
                            l("{}.attrs[{}].hlsl_sem_name := '{}';\n", desc, attr_index, attr.sem_name);
                            l("{}.attrs[{}].hlsl_sem_index := {};\n", desc, attr_index, attr.sem_index);
                        }
                    }
                }
            }
            for (int ub_index = 0; ub_index < MaxUniformBlocks; ub_index++) {
                const UniformBlock* ub = prog.bindings.find_uniform_block_by_sokol_slot(ub_index);
                if (ub) {
                    const std::string ubn = fmt::format("{}.uniform_blocks[{}]", desc, ub_index);
                    l("{}.stage := {};\n", ubn, shader_stage(ub->stage));
                    l("{}.layout := _SG_UNIFORMLAYOUT_STD140;\n", ubn);
                    l("{}.size := {};\n", ubn, roundup(ub->struct_info.size, 16));
                    if (Slang::is_hlsl(slang)) {
                        l("{}.hlsl_register_b_n := {};\n", ubn, ub->hlsl_register_b_n);
                    } else if (Slang::is_msl(slang)) {
                        l("{}.msl_buffer_n := {};\n", ubn, ub->msl_buffer_n);
                    } else if (Slang::is_wgsl(slang)) {
                        l("{}.wgsl_group0_binding_n := {};\n", ubn, ub->wgsl_group0_binding_n);
                    } else if (Slang::is_spirv(slang)) {
                        l("{}.spirv_set0_binding_n := {};\n", ubn, ub->spirv_set0_binding_n);
                    } else if (Slang::is_glsl(slang) && (ub->struct_info.struct_items.size() > 0)) {
                        if (ub->flattened) {
                            // NOT A BUG (to take the type from the first struct item, but the size from the toplevel ub)
                            l("{}.glsl_uniforms[0].type := {};\n", ubn, flattened_uniform_type(ub->struct_info.struct_items[0].type));
                            l("{}.glsl_uniforms[0].array_count := {};\n", ubn, roundup(ub->struct_info.size, 16) / 16);
                            l("{}.glsl_uniforms[0].glsl_name := '{}';\n", ubn, ub->name);
                        } else {
                            for (int u_index = 0; u_index < (int)ub->struct_info.struct_items.size(); u_index++) {
                                const Type& u = ub->struct_info.struct_items[u_index];
                                const std::string un = fmt::format("{}.glsl_uniforms[{}]", ubn, u_index);
                                l("{}.type := {};\n", un, uniform_type(u.type));
                                l("{}.array_count := {};\n", un, u.array_count);
                                l("{}.glsl_name := '{}.{}';\n", un, ub->inst_name, u.name);
                            }
                        }
                    }
                }
            }
            for (int view_index = 0; view_index < MaxViews; view_index++) {
                const Bindings::View view = prog.bindings.get_view_by_sokol_slot(view_index);
                if (view.type == BindSlot::Type::Texture) {
                    const Texture* tex = &view.texture;
                    const std::string& tn = fmt::format("{}.views[{}].texture", desc, view_index);
                    l("{}.stage := {};\n", tn, shader_stage(tex->stage));
                    l("{}.image_type := {};\n", tn, image_type(tex->type));
                    l("{}.sample_type := {};\n", tn, image_sample_type(tex->sample_type));
                    l("{}.multisampled := {};\n", tn, tex->multisampled ? "True" : "False");
                    if (Slang::is_hlsl(slang)) {
                        l("{}.hlsl_register_t_n := {};\n", tn, tex->hlsl_register_t_n);
                    } else if (Slang::is_msl(slang)) {
                        l("{}.msl_texture_n := {};\n", tn, tex->msl_texture_n);
                    } else if (Slang::is_wgsl(slang)) {
                        l("{}.wgsl_group1_binding_n := {};\n", tn, tex->wgsl_group1_binding_n);
                    } else if (Slang::is_spirv(slang)) {
                        l("{}.spirv_set1_binding_n := {};\n", tn, tex->spirv_set1_binding_n);
                    }
                } else if (view.type == BindSlot::Type::StorageBuffer) {
                    const StorageBuffer* sbuf = &view.storage_buffer;
                    const std::string& sbn = fmt::format("{}.views[{}].storage_buffer", desc, view_index);
                    l("{}.stage := {};\n", sbn, shader_stage(sbuf->stage));
                    l("{}.readonly := {};\n", sbn, sbuf->readonly);
                    if (Slang::is_hlsl(slang)) {
                        if (sbuf->hlsl_register_t_n >= 0) {
                            l("{}.hlsl_register_t_n := {};\n", sbn, sbuf->hlsl_register_t_n);
                        }
                        if (sbuf->hlsl_register_u_n >= 0) {
                            l("{}.hlsl_register_u_n := {};\n", sbn, sbuf->hlsl_register_u_n);
                        }
                    } else if (Slang::is_msl(slang)) {
                        l("{}.msl_buffer_n := {};\n", sbn, sbuf->msl_buffer_n);
                    } else if (Slang::is_wgsl(slang)) {
                        l("{}.wgsl_group1_binding_n := {};\n", sbn, sbuf->wgsl_group1_binding_n);
                    } else if (Slang::is_spirv(slang)) {
                        l("{}.spirv_set1_binding_n := {};\n", sbn, sbuf->spirv_set1_binding_n);
                    } else if (Slang::is_glsl(slang)) {
                        l("{}.glsl_binding_n := {};\n", sbn, sbuf->glsl_binding_n);
                    }
                } else if (view.type == BindSlot::Type::StorageImage) {
                    const StorageImage* simg = &view.storage_image;
                    const std::string& sin = fmt::format("{}.views[{}].storage_image", desc, view_index);
                    l("{}.stage := {};\n", sin, shader_stage(simg->stage));
                    l("{}.image_type := {};\n", sin, image_type(simg->type));
                    l("{}.access_format := {};\n", sin, storage_pixel_format(simg->access_format));
                    l("{}.writeonly := {};\n", sin, simg->writeonly);
                    if (Slang::is_hlsl(slang)) {
                        l("{}.hlsl_register_u_n := {};\n", sin, simg->hlsl_register_u_n);
                    } else if (Slang::is_msl(slang)) {
                        l("{}.msl_texture_n := {};\n", sin, simg->msl_texture_n);
                    } else if (Slang::is_wgsl(slang)) {
                        l("{}.wgsl_group1_binding_n := {};\n", sin, simg->wgsl_group1_binding_n);
                    } else if (Slang::is_spirv(slang)) {
                        l("{}.spirv_set1_binding_n := {};\n", sin, simg->spirv_set1_binding_n);
                    } else if (Slang::is_glsl(slang)) {
                        l("{}.glsl_binding_n := {};\n", sin, simg->glsl_binding_n);
                    }
                }
            }
            for (int smp_index = 0; smp_index < MaxSamplers; smp_index++) {
                const Sampler* smp = prog.bindings.find_sampler_by_sokol_slot(smp_index);
                if (smp) {
                    const std::string sn = fmt::format("{}.samplers[{}]", desc, smp_index);
                    l("{}.stage := {};\n", sn, shader_stage(smp->stage));
                    l("{}.sampler_type := {};\n", sn, sampler_type(smp->type));
                    if (Slang::is_hlsl(slang)) {
                        l("{}.hlsl_register_s_n := {};\n", sn, smp->hlsl_register_s_n);
                    } else if (Slang::is_msl(slang)) {
                        l("{}.msl_sampler_n := {};\n", sn, smp->msl_sampler_n);
                    } else if (Slang::is_wgsl(slang)) {
                        l("{}.wgsl_group1_binding_n := {};\n", sn, smp->wgsl_group1_binding_n);
                    } else if (Slang::is_spirv(slang)) {
                        l("{}.spirv_set1_binding_n := {};\n", sn, smp->spirv_set1_binding_n);
                    }
                }
            }
            for (int tex_smp_index = 0; tex_smp_index < MaxTextureSamplers; tex_smp_index++) {
                const TextureSampler* tex_smp = prog.bindings.find_texture_sampler_by_sokol_slot(tex_smp_index);
                if (tex_smp) {
                    const std::string tsn = fmt::format("{}.texture_sampler_pairs[{}]", desc, tex_smp_index);
                    l("{}.stage := {};\n", tsn, shader_stage(tex_smp->stage));
                    l("{}.view_slot := {};\n", tsn, prog.bindings.find_texture_by_name(tex_smp->texture_name)->sokol_slot);
                    l("{}.sampler_slot := {};\n", tsn, prog.bindings.find_sampler_by_name(tex_smp->sampler_name)->sokol_slot);
                    if (Slang::is_glsl(slang)) {
                        l("{}.glsl_name := '{}';\n", tsn, tex_smp->name);
                    }
                }
            }
            l("{}.&label := '{}{}_shader';\n", desc, mod_prefix, prog.name);
            l_close("end;\n");
            if (gen.args.ifdef) {
                l("{{$ENDIF !{}}}\n", sokol_define(slang));
            }
        }
    }
    l_close("end;\n\n");

    gen_shader_desc_func_prototype(prog);
    l_open("begin\n");
    l("if ({}.&label = nil) then\n", desc);
    l("  Init{}ShaderDesc;\n\n", prog_name);
    l("Result := @{};\n", desc);
    l_close("end;\n");
}

void SokolDelphiGenerator::gen_attr_slot_refl_func(const GenInput& gen, const ProgramReflection& prog) {
    l_open("{}int {}{}_attr_slot(const char* attr_name) {{\n", func_prefix, mod_prefix, prog.name);
    l("(void)attr_name;\n");
    for (const StageAttr& attr: prog.vs().inputs) {
        if (attr.slot >= 0) {
            l_open("if (0 == strcmp(attr_name, \"{}\")) {{\n", attr.name);
            l("return {};\n", attr.slot);
            l_close("}}\n");
        }
    }
    l("return -1;\n");
    l_close("}}\n");
}

void SokolDelphiGenerator::gen_texture_slot_refl_func(const GenInput& gen, const ProgramReflection& prog) {
    l_open("{}int {}{}_texture_slot(const char* tex_name) {{\n", func_prefix, mod_prefix, prog.name);
    l("(void)tex_name;\n");
    for (const Texture& tex: prog.bindings.textures) {
        if (tex.sokol_slot >= 0) {
            l_open("if (0 == strcmp(tex_name, \"{}\")) {{\n", tex.name);
            l("return {};\n", tex.sokol_slot);
            l_close("}}\n");
        }
    }
    l("return -1;\n");
    l_close("}}\n");
}

void SokolDelphiGenerator::gen_sampler_slot_refl_func(const GenInput& gen, const ProgramReflection& prog) {
    l_open("{}int {}{}_sampler_slot(const char* smp_name) {{\n", func_prefix, mod_prefix, prog.name);
    l("(void)smp_name;\n");
    for (const Sampler& smp: prog.bindings.samplers) {
        if (smp.sokol_slot >= 0) {
            l_open("if (0 == strcmp(smp_name, \"{}\")) {{\n", smp.name);
            l("return {};\n", smp.sokol_slot);
            l_close("}}\n");
        }
    }
    l("return -1;\n");
    l_close("}}\n");
}

void SokolDelphiGenerator::gen_uniform_block_slot_refl_func(const GenInput& gen, const ProgramReflection& prog) {
    l_open("{}int {}{}_uniformblock_slot(const char* ub_name) {{\n", func_prefix, mod_prefix, prog.name);
    l("(void)ub_name;\n");
    for (const UniformBlock& ub: prog.bindings.uniform_blocks) {
        if (ub.sokol_slot >= 0) {
            l_open("if (0 == strcmp(ub_name, \"{}\")) {{\n", ub.name);
            l("return {};\n", ub.sokol_slot);
            l_close("}}\n");
        }
    }
    l("return -1;\n");
    l_close("}}\n");
}

void SokolDelphiGenerator::gen_uniform_block_size_refl_func(const GenInput& gen, const ProgramReflection& prog) {
    l_open("{}size_t {}{}_uniformblock_size(const char* ub_name) {{\n", func_prefix, mod_prefix, prog.name);
    l("(void)ub_name;\n");
    for (const UniformBlock& ub: prog.bindings.uniform_blocks) {
        if (ub.sokol_slot >= 0) {
            l_open("if (0 == strcmp(ub_name, \"{}\")) {{\n", ub.name);
            l("return sizeof({});\n", struct_name(ub.name));
            l_close("}}\n");
        }
    }
    l("return 0;\n");
    l_close("}}\n");
}

void SokolDelphiGenerator::gen_storage_buffer_slot_refl_func(const GenInput& gen, const ProgramReflection& prog) {
    l_open("{}int {}{}_storagebuffer_slot(const char* sbuf_name) {{\n", func_prefix, mod_prefix, prog.name);
    l("(void)sbuf_name;\n");
    for (const StorageBuffer& sbuf: prog.bindings.storage_buffers) {
        if (sbuf.sokol_slot >= 0) {
            l_open("if (0 == strcmp(sbuf_name, \"{}\")) {{\n", sbuf.name);
            l("return {};\n", sbuf.sokol_slot);
            l_close("}}\n");
        }
    }
    l("return -1;\n");
    l_close("}}\n");
}

void SokolDelphiGenerator::gen_storage_image_slot_refl_func(const GenInput& gen, const ProgramReflection& prog) {
    l_open("{}int {}{}_storageimage_slot(const char* simg_name) {{\n", func_prefix, mod_prefix, prog.name);
    l("(void)simg_name;\n");
    for (const StorageImage& simg: prog.bindings.storage_images) {
        if (simg.sokol_slot >= 0) {
            l_open("if (0 == strcmp(simg_name, \"{}\")) {{\n", simg.name);
            l("return {};\n", simg.sokol_slot);
            l_close("}}\n");
        }
    }
    l("return -1;\n");
    l_close("}}\n");
}

void SokolDelphiGenerator::gen_uniform_offset_refl_func(const GenInput& gen, const ProgramReflection& prog) {
    l_open("{}int {}{}_uniform_offset(const char* ub_name, const char* u_name) {{\n", func_prefix, mod_prefix, prog.name);
    l("(void)ub_name; (void)u_name;\n");
    for (const UniformBlock& ub: prog.bindings.uniform_blocks) {
        if (ub.sokol_slot >= 0) {
            l_open("if (0 == strcmp(ub_name, \"{}\")) {{\n", ub.name);
            for (const Type& u: ub.struct_info.struct_items) {
                l_open("if (0 == strcmp(u_name, \"{}\")) {{\n", u.name);
                l("return {};\n", u.offset);
                l_close("}}\n");
            }
            l_close("}}\n");
        }
    }
    l("return -1;\n");
    l_close("}}\n");
}

void SokolDelphiGenerator::gen_uniform_desc_refl_func(const GenInput& gen, const ProgramReflection& prog) {
    l_open("{}sg_glsl_shader_uniform {}{}_uniform_desc(const char* ub_name, const char* u_name) {{\n", func_prefix, mod_prefix, prog.name);
    l("(void)ub_name; (void)u_name;\n");
    l("#if defined(__cplusplus)\n");
    l("sg_glsl_shader_uniform res = {{}};\n");
    l("#else\n");
    l("sg_glsl_shader_uniform res = {{0}};\n");
    l("#endif\n");
    for (const UniformBlock& ub: prog.bindings.uniform_blocks) {
        if (ub.sokol_slot >= 0) {
            l_open("if (0 == strcmp(ub_name, \"{}\")) {{\n", ub.name);
            for (const Type& u: ub.struct_info.struct_items) {
                l_open("if (0 == strcmp(u_name, \"{}\")) {{\n", u.name);
                l("res.type = {};\n", uniform_type(u.type));
                l("res.array_count = {};\n", u.array_count);
                l("res.glsl_name = \"{}\";\n", u.name);
                l("return res;\n");
                l_close("}}\n");
            }
            l_close("}}\n");
        }
    }
    l("return res;\n");
    l_close("}}\n");
}

void SokolDelphiGenerator::gen_shader_arrays(const GenInput& gen) {
    // Write function prototypes in interface section
    for (const auto& prog : gen.refl.progs) {
        gen_shader_desc_func_prototype(prog);
    }

    l("\nimplementation\n\n");
    l("uses\n");
    l("  Neslib.Sokol.Api;\n\n");

    Generator::gen_shader_arrays(gen);
}

void SokolDelphiGenerator::gen_shader_array_start(const GenInput& gen, const std::string& array_name, size_t num_bytes, Slang::Enum slang) {
    if (gen.args.ifdef) {
        l("{{$IFDEF {}}}\n", sokol_define(slang));
    }
    l("const\n");
    l("  {}: array [0..{}] of Byte = (\n", pystring::upper(array_name), num_bytes - 1);
}

void SokolDelphiGenerator::gen_shader_array_end(const GenInput& gen) {
    l(");\n");
    if (gen.args.ifdef) {
        l("{{$ENDIF}}\n\n");
    }
}

void SokolDelphiGenerator::gen_stb_impl_start(const GenInput &gen) {
    if (gen.args.output_format == Format::SOKOL_IMPL) {
        l("#if defined(SOKOL_SHDC_IMPL)\n");
    }
}

void SokolDelphiGenerator::gen_stb_impl_end(const GenInput& gen) {
    if (gen.args.output_format == Format::SOKOL_IMPL) {
        l("#endif // SOKOL_SHDC_IMPL");
    }
}

std::string SokolDelphiGenerator::lang_name() {
    return "C";
}

std::string SokolDelphiGenerator::shader_bytecode_array_name(const std::string& snippet_name, Slang::Enum slang) {
    return fmt::format("{}{}_bytecode_{}", mod_prefix, snippet_name, Slang::to_str(slang));
}

std::string SokolDelphiGenerator::shader_source_array_name(const std::string& snippet_name, Slang::Enum slang) {
    return fmt::format("{}{}_source_{}", mod_prefix, snippet_name, Slang::to_str(slang));
}

std::string SokolDelphiGenerator::comment_block_start() {
    return "(*";
}

std::string SokolDelphiGenerator::comment_block_end() {
    return "*)";
}

std::string SokolDelphiGenerator::comment_block_line_prefix() {
    return "";
}

std::string SokolDelphiGenerator::get_shader_desc_help(const std::string& prog_name) {
    return fmt::format("{}{}_shader_desc(sg_query_backend());\n", mod_prefix, prog_name);
}

std::string SokolDelphiGenerator::shader_stage(ShaderStage::Enum e) {
    switch (e) {
        case ShaderStage::Vertex: return "_SG_SHADERSTAGE_VERTEX";
        case ShaderStage::Fragment: return "_SG_SHADERSTAGE_FRAGMENT";
        case ShaderStage::Compute: return "_SG_SHADERSTAGE_COMPUTE";
        default: return "INVALID";
    }
}

std::string SokolDelphiGenerator::attr_basetype(Type::Enum e) {
    switch (e) {
        case Type::Float:   return "_SG_SHADERATTRBASETYPE_FLOAT";
        case Type::Int:     return "_SG_SHADERATTRBASETYPE_SINT";
        case Type::UInt:    return "_SG_SHADERATTRBASETYPE_UINT";
        default: return "INVALID";
    }
}

std::string SokolDelphiGenerator::uniform_type(Type::Enum e) {
    switch (e) {
        case Type::Float:  return "_SG_UNIFORMTYPE_FLOAT";
        case Type::Float2: return "_SG_UNIFORMTYPE_FLOAT2";
        case Type::Float3: return "_SG_UNIFORMTYPE_FLOAT3";
        case Type::Float4: return "_SG_UNIFORMTYPE_FLOAT4";
        case Type::Int:    return "_SG_UNIFORMTYPE_INT";
        case Type::Int2:   return "_SG_UNIFORMTYPE_INT2";
        case Type::Int3:   return "_SG_UNIFORMTYPE_INT3";
        case Type::Int4:   return "_SG_UNIFORMTYPE_INT4";
        case Type::Mat4x4: return "_SG_UNIFORMTYPE_MAT4";
        default: return "INVALID";
    }
}

std::string SokolDelphiGenerator::flattened_uniform_type(Type::Enum e) {
    switch (e) {
        case Type::Float:
        case Type::Float2:
        case Type::Float3:
        case Type::Float4:
        case Type::Mat4x4:
             return "_SG_UNIFORMTYPE_FLOAT4";
        case Type::Int:
        case Type::Int2:
        case Type::Int3:
        case Type::Int4:
            return "_SG_UNIFORMTYPE_INT4";
        default:
            return "INVALID";
    }
}

std::string SokolDelphiGenerator::image_type(ImageType::Enum e) {
    switch (e) {
        case ImageType::_2D:     return "_SG_IMAGETYPE_2D";
        case ImageType::CUBE:    return "_SG_IMAGETYPE_CUBE";
        case ImageType::_3D:     return "_SG_IMAGETYPE_3D";
        case ImageType::ARRAY:   return "_SG_IMAGETYPE_ARRAY";
        default: return "INVALID";
    }
}

std::string SokolDelphiGenerator::image_sample_type(ImageSampleType::Enum e) {
    switch (e) {
        case ImageSampleType::FLOAT: return "_SG_IMAGESAMPLETYPE_FLOAT";
        case ImageSampleType::DEPTH: return "_SG_IMAGESAMPLETYPE_DEPTH";
        case ImageSampleType::SINT:  return "_SG_IMAGESAMPLETYPE_SINT";
        case ImageSampleType::UINT:  return "_SG_IMAGESAMPLETYPE_UINT";
        case ImageSampleType::UNFILTERABLE_FLOAT:  return "_SG_IMAGESAMPLETYPE_UNFILTERABLE_FLOAT";
        default: return "INVALID";
    }
}

std::string SokolDelphiGenerator::sampler_type(SamplerType::Enum e) {
    switch (e) {
        case SamplerType::FILTERING:     return "_SG_SAMPLERTYPE_FILTERING";
        case SamplerType::COMPARISON:    return "_SG_SAMPLERTYPE_COMPARISON";
        case SamplerType::NONFILTERING:  return "_SG_SAMPLERTYPE_NONFILTERING";
        default: return "INVALID";
    }
}

std::string SokolDelphiGenerator::storage_pixel_format(refl::StoragePixelFormat::Enum e) {
    switch (e) {
        case StoragePixelFormat::RGBA8:     return "_SG_PIXELFORMAT_RGBA8";
        case StoragePixelFormat::RGBA8SN:   return "_SG_PIXELFORMAT_RGBA8SN";
        case StoragePixelFormat::RGBA8UI:   return "_SG_PIXELFORMAT_RGBA8UI";
        case StoragePixelFormat::RGBA8SI:   return "_SG_PIXELFORMAT_RGBA8SI";
        case StoragePixelFormat::RGBA16UI:  return "_SG_PIXELFORMAT_RGBA16UI";
        case StoragePixelFormat::RGBA16SI:  return "_SG_PIXELFORMAT_RGBA16SI";
        case StoragePixelFormat::RGBA16F:   return "_SG_PIXELFORMAT_RGBA16F";
        case StoragePixelFormat::R32UI:     return "_SG_PIXELFORMAT_R32UI";
        case StoragePixelFormat::R32SI:     return "_SG_PIXELFORMAT_R32SI";
        case StoragePixelFormat::R32F:      return "_SG_PIXELFORMAT_R32F";
        case StoragePixelFormat::RG32UI:    return "_SG_PIXELFORMAT_RG32UI";
        case StoragePixelFormat::RG32SI:    return "_SG_PIXELFORMAT_RG32SI";
        case StoragePixelFormat::RG32F:     return "_SG_PIXELFORMAT_RG32F";
        case StoragePixelFormat::RGBA32UI:  return "_SG_PIXELFORMAT_RGBA32UI";
        case StoragePixelFormat::RGBA32SI:  return "_SG_PIXELFORMAT_RGBA32SI";
        case StoragePixelFormat::RGBA32F:   return "_SG_PIXELFORMAT_RGBA32F";
        default: return "INVALID";
    }
}

std::string SokolDelphiGenerator::backend(Slang::Enum e) {
    switch (e) {
        case Slang::GLSL410:
        case Slang::GLSL430:
            return "TBackend.GLCore";
        case Slang::GLSL300ES:
        case Slang::GLSL310ES:
            return "TBackend.Gles3";
        case Slang::HLSL4:
        case Slang::HLSL5:
            return "TBackend.D3D11";
        case Slang::METAL_MACOS:
            return "TBackend.MetalMacOS";
        case Slang::METAL_IOS:
            return "TBackend.MetalIOS";
        case Slang::SPIRV_VK:
            return "TBackend.Vulkan";
        default:
            return "<INVALID>";
    }
}

std::string SokolDelphiGenerator::struct_name(const std::string& name) {
    auto words = pystring::split(name, "_");
    for (std::string& s : words) 
        s = delphi_case(s);
    
    auto s = pystring::join("", words);
    return fmt::format("T{}{}", mod_prefix, s);
}

std::string SokolDelphiGenerator::vertex_attr_name(const std::string& prog_name, const StageAttr& attr) {
    return pystring::upper(fmt::format("ATTR_{}{}_{}", mod_prefix, prog_name, attr.name));
}

std::string SokolDelphiGenerator::texture_bind_slot_name(const Texture& tex) {
    return pystring::upper(fmt::format("VIEW_{}{}", mod_prefix, tex.name));
}

std::string SokolDelphiGenerator::storage_buffer_bind_slot_name(const StorageBuffer& sbuf) {
    return pystring::upper(fmt::format("VIEW_{}{}", mod_prefix, sbuf.name));
}

std::string SokolDelphiGenerator::storage_image_bind_slot_name(const StorageImage& simg) {
    return pystring::upper(fmt::format("VIEW_{}{}", mod_prefix, simg.name));
}

std::string SokolDelphiGenerator::sampler_bind_slot_name(const Sampler& smp) {
    return pystring::upper(fmt::format("SMP_{}{}", mod_prefix, smp.name));
}

std::string SokolDelphiGenerator::uniform_block_bind_slot_name(const UniformBlock& ub) {
    return pystring::upper(fmt::format("UB_{}{}", mod_prefix, ub.name));
}

std::string SokolDelphiGenerator::vertex_attr_definition(const std::string& prog_name, const StageAttr& attr) {
    return fmt::format("  {} = {};", vertex_attr_name(prog_name, attr), attr.slot);
}

std::string SokolDelphiGenerator::texture_bind_slot_definition(const Texture& tex) {
    return fmt::format("  {} = {};", texture_bind_slot_name(tex), tex.sokol_slot);
}

std::string SokolDelphiGenerator::sampler_bind_slot_definition(const Sampler& smp) {
    return fmt::format("  {} = {};", sampler_bind_slot_name(smp), smp.sokol_slot);
}

std::string SokolDelphiGenerator::uniform_block_bind_slot_definition(const UniformBlock& ub) {
    return fmt::format("  {} = {};", uniform_block_bind_slot_name(ub), ub.sokol_slot);
}

std::string SokolDelphiGenerator::storage_buffer_bind_slot_definition(const StorageBuffer& sbuf) {
    return fmt::format("  {} = {};", storage_buffer_bind_slot_name(sbuf), sbuf.sokol_slot);
}

std::string SokolDelphiGenerator::storage_image_bind_slot_definition(const StorageImage& simg) {
    return fmt::format("  {} = {};", storage_image_bind_slot_name(simg), simg.sokol_slot);
}

} // namespace
