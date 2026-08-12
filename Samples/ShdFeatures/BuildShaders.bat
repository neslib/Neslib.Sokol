..\..\Tools\sokol-shdc.exe --input ShdFeaturesShader.glsl --output ShdFeaturesShader.None.pas --defines NONE --module none --reflection
..\..\Tools\sokol-shdc.exe --input ShdFeaturesShader.glsl --output ShdFeaturesShader.SLM.pas --defines SKINNING:LIGHTING:MATERIAL --module slm --reflection
..\..\Tools\sokol-shdc.exe --input ShdFeaturesShader.glsl --output ShdFeaturesShader.SL.pas --defines SKINNING:LIGHTING --module sl --reflection
..\..\Tools\sokol-shdc.exe --input ShdFeaturesShader.glsl --output ShdFeaturesShader.S.pas --defines SKINNING --module s --reflection
..\..\Tools\sokol-shdc.exe --input ShdFeaturesShader.glsl --output ShdFeaturesShader.SM.pas --defines SKINNING:MATERIAL --module sm --reflection
..\..\Tools\sokol-shdc.exe --input ShdFeaturesShader.glsl --output ShdFeaturesShader.LM.pas --defines LIGHTING:MATERIAL --module lm --reflection
..\..\Tools\sokol-shdc.exe --input ShdFeaturesShader.glsl --output ShdFeaturesShader.M.pas --defines MATERIAL --module m --reflection
..\..\Tools\sokol-shdc.exe --input ShdFeaturesShader.glsl --output ShdFeaturesShader.L.pas --defines LIGHTING --module l --reflection