Shader "koturn/SphereTracingTips/04_LightingPlus/VRCLVAndLTCGI"
{
    Properties
    {
        // ------------------------------------------------------------
        [Header(Ray Marching Parameters)]
        [Space(8)]

        [IntRange]
        _MaxLoop ("Maximum loop count for ForwardBase", Range(8, 1024)) = 128

        _MinMarchingLength ("Minimum marching length", Float) = 0.001

        _MaxRayLength ("Maximum length of the ray", Float) = 1000.0

        _Scales ("Scale vector", Vector) = (1.0, 1.0, 1.0, 1.0)

        [KeywordEnum(Object, World)]
        _CalcSpace ("Calculation space", Int) = 0

        [Toggle(_SVDEPTH_ON)]
        _SVDepth ("SV_Depth ouput", Int) = 1

        _MarchingFactor ("Marching Factor", Range(0.5, 1.0)) = 1.0


        // ------------------------------------------------------------
        [Header(Lighting Parameters)]
        [Space(8)]
        _Color ("Color of the objects", Color) = (1.0, 1.0, 1.0, 1.0)

        [KeywordEnum(Unity Lambert, Unity Blinn Phong, Unity Standard, Unity Standard Specular, Unlit, Custom)]
        _Lighting ("Lighting method", Int) = 2

        _Glossiness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0

        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _SpecPower ("Specular Power", Range(0.0, 128.0)) = 16.0

        [ToggleOff(_SPECULARHIGHLIGHTS_OFF)]
        _SpecularHighlights ("Specular Highlights", Int) = 1

        [ToggleOff(_GLOSSYREFLECTIONS_OFF)]
        _GlossyReflections ("Glossy Reflections", Int) = 1

        [KeywordEnum(Off, On, Additive Only)]
        _VRCLightVolumes ("VRC Light Volumes", Int) = 0

        [KeywordEnum(Off, On, Dominant Dir)]
        _VRCLightVolumesSpecular ("VRC Light Volumes Specular", Int) = 0

        [Toggle(_LTCGI_ON)]
        _LTCGI ("LTCGI", Int) = 0


        // ------------------------------------------------------------
        [Header(Rendering Parameters)]
        [Space(8)]
        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull ("Culling Mode", Int) = 2  // Default: Back

        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlend ("Blend Source Factor", Int) = 1  // Default: One

        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend ("Blend Destination Factor", Int) = 0  // Default: Zero

        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlendAlpha ("Blend Source Factor for Alpha", Int) = 1  // Default: One

        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlendAlpha ("Blend Destination Factor for Alpha", Int) = 0  // Default: Zero

        [Enum(UnityEngine.Rendering.BlendOp)]
        _BlendOp ("Blend Operation", Int) = 0  // Default: Add

        [Enum(UnityEngine.Rendering.BlendOp)]
        _BlendOpAlpha ("Blend Operation for Alpha", Int) = 0  // Default: Add

        [Enum(Off, 0, On, 1)]
        _ZWrite ("ZWrite", Int) = 1  // Default: On

        [Enum(UnityEngine.Rendering.CompareFunction)]
        _ZTest ("ZTest", Int) = 4  // Default: LEqual

        [Enum(False, 0, True, 1)]
        _ZClip ("ZClip", Int) = 1  // Default: True

        _OffsetFactor ("Offset Factor", Range(-1.0, 1.0)) = 0
        _OffsetUnits ("Offset Units", Range(-1.0, 1.0)) = 0

        [ColorMask]
        _ColorMask ("Color Mask", Int) = 15  // Default: RGBA

        [Enum(Off, 0, On, 1)]
        _AlphaToMask ("Alpha To Mask", Int) = 0  // Default: Off
    }

    SubShader
    {
        // Not set RenderType to avoid phantom shadows when using Scalable Ambient Obscurance.
        // If you want to set the RenderType, "Transparent" is preferable.
        Tags
        {
            "Queue" = "AlphaTest"
            // "RenderType" = "Transparent"
            "DisableBatching" = "True"
            "IgnoreProjector" = "True"
            "VRCFallback" = "Hidden"
            "LTCGI" = "ALWAYS"
        }

        Cull [_Cull]
        BlendOp [_BlendOp], [_BlendOpAlpha]
        ZTest [_ZTest]
        ZClip [_ZClip]
        Offset [_OffsetFactor], [_OffsetUnits]
        ColorMask [_ColorMask]
        AlphaToMask [_AlphaToMask]

        CGINCLUDE
        #pragma target 3.0
        #pragma shader_feature_local _CALCSPACE_OBJECT _CALCSPACE_WORLD
        #pragma shader_feature_local_fragment _ _SVDEPTH_ON

        #if defined(_VRCLIGHTVOLUMES_ON) || defined(_VRCLIGHTVOLUMES_ADDITIVE_ONLY) || defined(_VRCLIGHTVOLUMESSPECULAR_ON) || defined(_VRCLIGHTVOLUMESSPECULAR_DOMINANT_DIR)
        #    define USE_VRCLIGHTVOLUMES
        #endif  // defined(_VRCLIGHTVOLUMES_ON) || defined(_VRCLIGHTVOLUMES_ADDITIVE_ONLY) || defined(_VRCLIGHTVOLUMESSPECULAR_ON) || defined(_VRCLIGHTVOLUMESSPECULAR_DOMINANT_DIR)

        #include "UnityCG.cginc"
        #include "UnityStandardUtils.cginc"

        #include "AutoLight.cginc"
        #include "Lighting.cginc"
        #include "UnityPBSLighting.cginc"

        #if defined(USE_VRCLIGHTVOLUMES)
        #    include "Packages/red.sim.lightvolumes/Shaders/LightVolumes.cginc"
        #endif  // defined(USE_VRCLIGHTVOLUMES)

        #if defined(_LTCGI_ON)
        #    define LTCGI_AVATAR_MODE
        #    if defined(_LIGHTING_UNITY_LAMBERT)
        #        define LTCGI_SPECULAR_OFF
        #    endif  // defined(_LIGHTING_UNITY_LAMBERT)
        #    include "Packages/at.pimaker.ltcgi/Shaders/LTCGI.cginc"
        #endif  // defined(_LTCGI_ON)


        //! Maximum loop count for ForwardBase.
        uniform int _MaxLoop;
        //! Minimum marching length.
        uniform float _MinMarchingLength;
        //! Maximum length of the ray.
        uniform float _MaxRayLength;
        //! Scale vector.
        uniform float3 _Scales;
        //! Marching Factor.
        uniform float _MarchingFactor;
        //! Color of the objects.
        uniform half4 _Color;
        //! Value of smoothness.
        uniform half _Glossiness;
        //! Value of Metallic.
        uniform half _Metallic;
        //! Specular power.
        uniform float _SpecPower;


        /*!
         * @brief Input data type for vertex shader function, vert().
         * @see vert
         */
        struct appdata
        {
            //! Object space position of the vertex.
            float4 vertex : POSITION;
        #if defined(LIGHTMAP_ON)
            //! Lightmap coordinate.
            float4 texcoord1 : TEXCOORD1;
        #endif  // defined(LIGHTMAP_ON)
        #if defined(DYNAMICLIGHTMAP_ON)
            //! Dynamic Lightmap coordinate.
            float4 texcoord2 : TEXCOORD2;
        #endif  // defined(DYNAMICLIGHTMAP_ON)
            // Instance ID for single pass instanced rendering, `uint instanceID : SV_InstanceID`.
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        /*!
         * @brief Output of the vertex shader, vert()
         * and input of fragment shader, frag().
         * @see vert
         * @see frag
         */
        struct v2f
        {
            //! Clip space position of the vertex.
            float4 pos : SV_POSITION;
            //! Object/World space position of the fragment.
            float3 fragPos : TEXCOORD0;
        #if !defined(_CALCSPACE_WORLD)
            //! Camera position in object space. (for pre-calulation on vertex shader)
            nointerpolation float3 cameraPos : TEXCOORD1;
        #endif  // !defined(_CALCSPACE_WORLD)
            // Members abourt lighting coordinates, `_LightCoord` and `_ShadowCoord`.
            UNITY_LIGHTING_COORDS(3, 4)
            // Instance ID for single pass instanced rendering, `uint instanceID : SV_InstanceID`.
            UNITY_VERTEX_INPUT_INSTANCE_ID
            // Stereo target eye index for single pass instanced rendering, `stereoTargetEyeIndex` and `stereoTargetEyeIndexSV`.
            UNITY_VERTEX_OUTPUT_STEREO
        };

        /*!
         * @brief Output of fragment shader.
         * @see frag
         */
        struct fout
        {
            //! Output color of the pixel.
            half4 color : SV_Target;
        #if defined(_SVDEPTH_ON)
            //! Depth of the pixel.
            float depth : SV_Depth;
        #endif  // defined(_SVDEPTH_ON)
        };


        float map(float3 p);
        float sdSphere(float3 p, float r);
        float3 calcNormal(float3 p);
        float getDepth(float4 clipPos);
        half4 calcLighting(half4 color, float3 worldPos, float3 worldNormal, half atten, half3 ambient);
        half4 calcLightingUnity(half4 color, float3 worldPos, float3 worldNormal, half atten, half3 ambient);
        half4 calcLightingCustom(half4 color, float3 worldPos, float3 worldNormal, half atten, half3 ambient);
        UnityGI getGI(float3 worldPos, half atten);
        UnityGIInput getGIInput(UnityLight light, float3 worldPos, float3 worldNormal, float3 worldViewDir, half atten, float4 lmap, half3 ambient);
        #if defined(USE_VRCLIGHTVOLUMES)
        half3 calcLightVolumeEmission(half3 albedo, float3 worldPos, float3 worldNormal, float3 worldViewDir, half glossiness, half metallic);
        #endif  // defined(USE_VRCLIGHTVOLUMES)


        /*!
         * @brief Vertex shader function.
         * @param [in] v  Input data.
         * @return Interpolation source data for fragment shader function, frag().
         * @see frag
         */
        v2f vert(appdata v)
        {
            v2f o;
            UNITY_INITIALIZE_OUTPUT(v2f, o);

            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_TRANSFER_INSTANCE_ID(v, o);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        #if defined(_CALCSPACE_WORLD)
            o.fragPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        #else
            o.fragPos = v.vertex.xyz;
            o.cameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz;
        #endif  // defined(_CALCSPACE_WORLD)

            UNITY_TRANSFER_LIGHTING(o, v.texcoord1);

            o.pos = UnityObjectToClipPos(v.vertex);

            return o;
        }

        /*!
         * @brief Fragment shader function.
         * @param [in] fi  Input data from vertex shader.
         * @return Color and depth of fragment.
         */
        fout frag(v2f fi)
        {
            UNITY_SETUP_INSTANCE_ID(fi);
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(fi);

        #if defined(_CALCSPACE_WORLD)
            const float3 rayOrigin = _WorldSpaceCameraPos;
        #else
            const float3 rayOrigin = fi.cameraPos;
        #endif  // defined(_CALCSPACE_WORLD)
            const float3 rayDir = normalize(fi.fragPos - rayOrigin);

            const float3 rcpScales = rcp(_Scales);
            const float dcRate = rsqrt(dot(rayDir * rcpScales, rayDir * rcpScales));
            const float minMarchingLength = _MinMarchingLength * dcRate;
            const float maxRayLength = _MaxRayLength * dcRate;

            float rayLength = 0.0;
            float d = asfloat(0x7f800000);  // +inf
            for (int rayStep = 0; d >= minMarchingLength && rayLength < maxRayLength && rayStep < _MaxLoop; rayStep++) {
                d = map((rayOrigin + rayDir * rayLength) * rcpScales) * dcRate * _MarchingFactor;
                rayLength += d;
            }

            if (d >= minMarchingLength) {
                discard;
            }

        #if defined(_CALCSPACE_WORLD)
            const float3 worldFinalPos = rayOrigin + rayDir * rayLength;
            const float3 worldNormal = calcNormal(worldFinalPos);
        #else
            const float3 localFinalPos = rayOrigin + rayDir * rayLength;
            const float3 worldFinalPos = mul(unity_ObjectToWorld, float4(localFinalPos, 1.0)).xyz;
            const float3 localNormal = calcNormal(localFinalPos);
            const float3 worldNormal = UnityObjectToWorldNormal(localNormal);
        #endif  // defined(_CALCSPACE_WORLD)

            UNITY_LIGHT_ATTENUATION(atten, fi, worldFinalPos);

            half4 color = calcLighting(
                _Color,
                worldFinalPos,
                worldNormal,
                atten,
                half3(0.0, 0.0, 0.0));

            const float4 clipPos = UnityWorldToClipPos(worldFinalPos);

            UNITY_APPLY_FOG(clipPos.z, color);

            fout fo;
            fo.color = color;
        #if defined(_SVDEPTH_ON)
            fo.depth = getDepth(clipPos);
        #endif  // defined(_SVDEPTH_ON)

            return fo;
        }

        /*!
         * @brief SDF (Signed Distance Function) of objects.
         * @param [in] p  Position of the tip of the ray.
         * @return Signed Distance to the objects.
         */
        float map(float3 p)
        {
            return sdSphere(p, 0.5);
        }

        /*!
         * @brief SDF of sphere.
         * @param [in] p  Position of the tip of the ray.
         * @param [in] r  Radius of sphere.
         * @return Signed Distance to the sphere.
         */
        float sdSphere(float3 p, float r)
        {
            return length(p) - r;
        }

        /*!
         * @brief Calculate normal of the objects with tetrahedron technique.
         * @param [in] p  Position of the tip of the ray.
         * @return Normal of the objects.
         * @see https://iquilezles.org/articles/normalsSDF/
         */
        float3 calcNormal(float3 p)
        {
            static const float2 k = float2(1.0, -1.0);
            static const float3 ks[] = {k.xyy, k.yxy, k.yyx, k.xxx};
            static const float h = 0.0001;

            const float3 rcpScales = rcp(_Scales);
            float3 normal = float3(0.0, 0.0, 0.0);

            for (int i = 0; i < 4; i++) {
                normal += ks[i] * map((p + ks[i] * h) * rcpScales);
            }

            return normalize(normal);
        }

        /*!
         * Calculate lighting.
         * @param [in] color  Base color.
         * @param [in] worldPos  World coordinate.
         * @param [in] worldNormal  Normal in world space.
         * @param [in] atten  Light attenuation.
         * @param [in] ambient  Ambient light.
         * @return Lighting applied color.
         */
        half4 calcLighting(half4 color, float3 worldPos, float3 worldNormal, half atten, half3 ambient)
        {
        #if defined(_LIGHTING_CUSTOM)
            return calcLightingCustom(color, worldPos, worldNormal, atten, ambient);
        #elif defined(_LIGHTING_UNITY_LAMBERT) \
            || defined(_LIGHTING_UNITY_BLINN_PHONG) \
            || defined(_LIGHTING_UNITY_STANDARD) \
            || defined(_LIGHTING_UNITY_STANDARD_SPECULAR)
            return calcLightingUnity(color, worldPos, worldNormal, atten, ambient);
        #else
            // assume _LIGHTING_UNLIT
            return color;
        #endif  // defined(_LIGHTING_CUSTOM)
        }

        /*!
         * Calculate lighting.
         * @param [in] color  Base color.
         * @param [in] worldPos  World coordinate.
         * @param [in] worldNormal  Normal in world space.
         * @param [in] atten  Light attenuation.
         * @param [in] ambient  Ambient light.
         * @return Lighting applied color.
         */
        half4 calcLightingUnity(half4 color, float3 worldPos, float3 worldNormal, half atten, half3 ambient)
        {
            // Uniform variable requirements:
            //
            // Variant                             | `_Glossiness` | `_Metallic` | `_SpecColor` | `_SpecPower`
            // ------------------------------------|---------------|-------------|--------------|-------------
            // `_LIGHTING_UNITY_LAMBERT`           |               |             |              |
            // `_LIGHTING_UNITY_BLINN_PHONG`       | o             |             | o            | o
            // `_LIGHTING_UNITY_STANDARD`          | o             | o           |              |
            // `_LIGHTING_UNITY_STANDARD_SPECULAR` | o             |             | o            |

        #if defined(_LIGHTING_UNITY_STANDARD)
        #    define LightingUnity_GI(so, giInput, gi) LightingStandard_GI(so, giInput, gi)
        #    define LightingUnity(so, worldViewDir, gi) LightingStandard(so, worldViewDir, gi)
            SurfaceOutputStandard so;
            UNITY_INITIALIZE_OUTPUT(SurfaceOutputStandard, so);
            so.Albedo = color.rgb;
            so.Normal = worldNormal;
            so.Emission = half3(0.0, 0.0, 0.0);
            so.Metallic = _Metallic;
            so.Smoothness = _Glossiness;
            so.Occlusion = 1.0;
            so.Alpha = color.a;
        #elif defined(_LIGHTING_UNITY_STANDARD_SPECULAR)
        #    define LightingUnity_GI(so, giInput, gi) LightingStandardSpecular_GI(so, giInput, gi)
        #    define LightingUnity(so, worldViewDir, gi) LightingStandardSpecular(so, worldViewDir, gi)
            SurfaceOutputStandardSpecular so;
            UNITY_INITIALIZE_OUTPUT(SurfaceOutputStandardSpecular, so);
            so.Albedo = color.rgb;
            so.Specular = _SpecColor.rgb;
            so.Normal = worldNormal;
            so.Emission = half3(0.0, 0.0, 0.0);
            so.Smoothness = _Glossiness;
            so.Occlusion = 1.0;
            so.Alpha = color.a;
        #else
            SurfaceOutput so;
            UNITY_INITIALIZE_OUTPUT(SurfaceOutput, so);
            so.Albedo = color.rgb;
            so.Normal = worldNormal;
            so.Emission = fixed3(0.0, 0.0, 0.0);
        #    if defined(_LIGHTING_UNITY_BLINN_PHONG)
        #        define LightingUnity_GI(so, giInput, gi) LightingBlinnPhong_GI(so, giInput, gi)
        #        define LightingUnity(so, worldViewDir, gi) LightingBlinnPhong(so, worldViewDir, gi)
            so.Specular = _SpecPower / 128.0;
            so.Gloss = _Glossiness;
            // NOTE: _SpecColor is used in UnityBlinnPhongLight() used in LightingBlinnPhong().
        #    else
        #        define LightingUnity_GI(so, giInput, gi) LightingLambert_GI(so, giInput, gi)
        #        define LightingUnity(so, worldViewDir, gi) LightingLambert(so, gi)
        #    endif  // defined(_LIGHTING_UNITY_BLINN_PHONG)
            so.Alpha = color.a;
        #endif  // defined(_LIGHTING_UNITY_STANDARD)

            UnityGI gi = getGI(worldPos, atten);
            const float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
        #if defined(UNITY_PASS_FORWARDBASE)
            const float4 lmap = float4(0.0, 0.0, 0.0, 0.0);
            UnityGIInput giInput = getGIInput(gi.light, worldPos, worldNormal, worldViewDir, atten, lmap, ambient);
            LightingUnity_GI(so, giInput, /* inout */ gi);
        #endif  // defined(UNITY_PASS_FORWARDBASE)

        #if UNITY_SHOULD_SAMPLE_SH && !defined(LIGHTMAP_ON)
        #    if defined(_LIGHTING_UNITY_STANDARD) || defined(_LIGHTING_UNITY_STANDARD_SPECULAR) || defined(_LIGHTING_UNITY_BLINN_PHONG)
                const half glossiness = _Glossiness;
        #    else
                const half glossiness = 0.0;
        #    endif  // defined(_LIGHTING_UNITY_STANDARD) || defined(_LIGHTING_UNITY_STANDARD_SPECULAR) || defined(_LIGHTING_UNITY_BLINN_PHONG)
        #    if defined(USE_VRCLIGHTVOLUMES)
            if (_UdonLightVolumeEnabled && _UdonLightVolumeCount != 0) {
        #        if defined(_LIGHTING_UNITY_STANDARD)
                const half metallic = _Metallic;
        #        else
                const half metallic = 0.0;
        #        endif  // defined(_LIGHTING_UNITY_STANDARD)
                gi.indirect.diffuse = half3(0.0, 0.0, 0.0);
                so.Emission += calcLightVolumeEmission(color.rgb, worldPos, worldNormal, worldViewDir, glossiness, metallic);
            }
        #    endif  // defined(USE_VRCLIGHTVOLUMES)
        #    if defined(_LTCGI_ON)
            float3 ltcgiSpecular = float3(0.0, 0.0, 0.0);
            float3 ltcgiDiffuse = float3(0.0, 0.0, 0.0);
            LTCGI_Contribution(
               worldPos,
               worldNormal,
               worldViewDir,
               1.0 - lossiness,
               float2(0.0, 0.0),
               /* inout */ ltcgiDiffuse,
               /* inout */ ltcgiSpecular);
        #        if defined(LTCGI_SPECULAR_OFF)
            so.Emission += color.rgb * ltcgiDiffuse;
        #        else
            so.Emission += color.rgb * ltcgiDiffuse + ltcgiSpecular;
        #        endif  // defined(LTCGI_SPECULAR_OFF)
        #    endif  // defined(_LTCGI_ON)
        #endif  // UNITY_SHOULD_SAMPLE_SH && !defined(LIGHTMAP_ON)

            half4 col = LightingUnity(so, worldViewDir, gi);
        #if defined(UNITY_PASS_FORWARDBASE)
            col.rgb += so.Emission;
        #endif  // defined(UNITY_PASS_FORWARDBASE)

            return col;

        #undef LightingUnity_GI
        #undef LightingUnity
        }

        /*!
         * Calculate lighting with custom method.
         * @param [in] color  Base color.
         * @param [in] worldPos  World coordinate.
         * @param [in] worldNormal  Normal in world space.
         * @param [in] atten  Light attenuation.
         * @param [in] ambient  Ambient light.
         * @return Lighting applied color.
         */
        half4 calcLightingCustom(half4 color, float3 worldPos, float3 worldNormal, half atten, half3 ambient)
        {
            const float3 worldViewDir = normalize(_WorldSpaceCameraPos - worldPos);
        #if defined(USING_LIGHT_MULTI_COMPILE) && defined(USING_DIRECTIONAL_LIGHT)
            const float3 worldLightDir = UnityWorldSpaceLightDir(worldPos);
        #else
            const float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
        #endif  // defined(USING_LIGHT_MULTI_COMPILE) && defined(USING_DIRECTIONAL_LIGHT)
            const fixed3 lightCol = _LightColor0.rgb * atten;

            // Lambertian reflectance.
            const float nDotL = dot(worldNormal, worldLightDir);
            const half3 diffuse = lightCol * pow(nDotL * 0.5 + 0.5, 2.0);  // will be mul instruction.

            // Specular reflection.
            const float nDotH = dot(worldNormal, normalize(worldLightDir + worldViewDir));
            const half3 specular = pow(max(0.0, nDotH), _SpecPower) * _SpecColor.rgb * lightCol;

            // Ambient color.
        #if UNITY_SHOULD_SAMPLE_SH
        #    if defined(USE_VRCLIGHTVOLUMES)
            ambient = calcLightVolumeEmission(color.rgb, worldPos, worldNormal, worldViewDir, 0.0, 0.0);
        #    else
            ambient = ShadeSHPerPixel(worldNormal, ambient, worldPos);
        #    endif  // defined(USE_VRCLIGHTVOLUMES)
        #endif  // UNITY_SHOULD_SAMPLE_SH

            half4 outColor = half4((diffuse + ambient) * color.rgb + specular, color.a);

        #if defined(_LTCGI_ON)
            float3 ltcgiSpecular = float3(0.0, 0.0, 0.0);
            float3 ltcgiDiffuse = float3(0.0, 0.0, 0.0);
            LTCGI_Contribution(
               worldPos,
               worldNormal,
               worldViewDir,
               1.0 - lossiness,
               float2(0.0, 0.0),
               /* inout */ ltcgiDiffuse,
               /* inout */ ltcgiSpecular);
        #    if defined(LTCGI_SPECULAR_OFF)
            outColor.rgb += color.rgb * ltcgiDiffuse;
        #    else
            outColor.rgb += color.rgb * ltcgiDiffuse + ltcgiSpecular;
        #    endif  // defined(LTCGI_SPECULAR_OFF)
        #endif  // defined(_LTCGI_ON)

            return outColor;
        }

        #if defined(USE_VRCLIGHTVOLUMES)
        /*!
         * @brief Calculate ambient of VRC Light Volumes.
         * @param [in] albedo  Albedo.
         * @param [in] worldPos  World coordinate.
         * @param [in] worldNormal  Normal in world space.
         * @param [in] worldViewDir  View direction in world space.
         * @return Ambient color.
         */
        half3 calcLightVolumeEmission(half3 albedo, float3 worldPos, float3 worldNormal, float3 worldViewDir, half glossiness, half metallic)
        {
        #    if defined(_VRCLIGHTVOLUMES_ADDITIVE)
            float3 L0, L1r, L1g, L1b;
            LightVolumeAdditiveSH(worldPos, /* out */ L0, /* out */ L1r, /* out */ L1g, /* out */ L1b);
        #    elif defined(_VRCLIGHTVOLUMES_ON)
            float3 L0, L1r, L1g, L1b;
            LightVolumeSH(worldPos, /* out */ L0, /* out */ L1r, /* out */ L1g, /* out */ L1b);
        #    else
            const float3 L0 = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
            const float3 L1r = unity_SHAr.xyz;
            const float3 L1g = unity_SHAg.xyz;
            const float3 L1b = unity_SHAb.xyz;
        #    endif  // defined(_VRCLIGHTVOLUMES_ADDITIVE)

            const float3 indirect = LightVolumeEvaluate(worldNormal, L0, L1r, L1g, L1b) * albedo;
            half3 emission = indirect - indirect * metallic;

        #    if defined(_VRCLIGHTVOLUMESSPECULAR_DOMINANT_DIR)
            emission += LightVolumeSpecularDominant(albedo, glossiness, metallic, worldNormal, worldViewDir, L0, L1r, L1g, L1b);
        #    elif defined(_VRCLIGHTVOLUMESSPECULAR_ON)
            emission += LightVolumeSpecular(albedo, glossiness, metallic, worldNormal, worldViewDir, L0, L1r, L1g, L1b);
        #    endif  // defined(_VRCLIGHTVOLUMESSPECULAR_DOMINANT_DIR)

            return emission;
        }
        #endif  // defined(USE_VRCLIGHTVOLUMES)

        /*!
         * @brief Get depth from clip space position.
         * @param [in] clipPos  Clip space position.
         * @return Depth value.
         */
        float getDepth(float4 clipPos)
        {
            const float depth = clipPos.z / clipPos.w;
        #if defined(SHADER_API_GLCORE) \
            || defined(SHADER_API_OPENGL) \
            || defined(SHADER_API_GLES) \
            || defined(SHADER_API_GLES3)
            // [-1.0, 1.0] -> [0.0, 1.0]
            // Near: -1.0
            // Far: 1.0
            return depth * 0.5 + 0.5;
        #else
            // [0.0, 1.0] -> [0.0, 1.0] (No conversion)
            // Near: 1.0
            // Far: 0.0
            return depth;
        #endif
        }

        /*!
         * @brief Get initial instance of UnityGI.
         * @param [in] worldPos  World coordinate.
         * @param [in] atten  Light attenuation.
         * @return Initial instance of UnityGI.
         */
        UnityGI getGI(float3 worldPos, half atten)
        {
            UnityGI gi;
            UNITY_INITIALIZE_OUTPUT(UnityGI, gi);

        #if defined(UNITY_PASS_FORWARDBASE)
            gi.light.color = _LightColor0.rgb;
        #elif defined(UNITY_PASS_DEFERRED)
            gi.light.color = half3(0.0, 0.0, 0.0);
        #else
            gi.light.color = _LightColor0.rgb * atten;
        #endif  // defined(UNITY_PASS_FORWARDBASE)
        #if defined(UNITY_PASS_DEFERRED)
            gi.light.dir = half3(0.0, 1.0, 0.0);
        #elif defined(USING_LIGHT_MULTI_COMPILE) && defined(USING_DIRECTIONAL_LIGHT)
            gi.light.dir = UnityWorldSpaceLightDir(worldPos);
        #else
            gi.light.dir = normalize(UnityWorldSpaceLightDir(worldPos));
        #endif  // defined(UNITY_PASS_DEFERRED)
            // gi.indirect.diffuse = half3(0.0, 0.0, 0.0);
            // gi.indirect.specular = half3(0.0, 0.0, 0.0);

            return gi;
        }

        /*!
         * @brief Get initial instance of UnityGIInput.
         * @param [in] light  The lighting parameter which contains color and direction of the light.
         * @param [in] worldPos  World coordinate.
         * @param [in] worldNormal  Normal in world space.
         * @param [in] worldViewDir  View direction in world space.
         * @param [in] atten  Light attenuation.
         * @param [in] lmap  Light map parameters.
         * @param [in] ambient  Ambient light.
         * @return Initial instance of UnityGIInput.
         */
        UnityGIInput getGIInput(UnityLight light, float3 worldPos, float3 worldNormal, float3 worldViewDir, half atten, float4 lmap, half3 ambient)
        {
            UnityGIInput giInput;
            UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
            giInput.light = light;
            giInput.worldPos = worldPos;
            giInput.worldViewDir = worldViewDir;
            giInput.atten = atten;

        #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
            giInput.lightmapUV = lmap;
        #else
            giInput.lightmapUV = float4(0.0, 0.0, 0.0, 0.0);
        #endif  // defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)

        #if UNITY_SHOULD_SAMPLE_SH
            giInput.ambient = ambient;
        #else
            giInput.ambient = half3(0.0, 0.0, 0.0);
        #endif  // UNITY_SHOULD_SAMPLE_SH

            giInput.probeHDR[0] = unity_SpecCube0_HDR;
            giInput.probeHDR[1] = unity_SpecCube1_HDR;
        #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
            giInput.boxMin[0] = unity_SpecCube0_BoxMin;
        #endif  // defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
        #if defined(UNITY_SPECCUBE_BOX_PROJECTION)
            giInput.boxMax[0] = unity_SpecCube0_BoxMax;
            giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
            giInput.boxMax[1] = unity_SpecCube1_BoxMax;
            giInput.boxMin[1] = unity_SpecCube1_BoxMin;
            giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
        #endif  // defined(UNITY_SPECCUBE_BOX_PROJECTION)

            return giInput;
        }
        ENDCG

        Pass
        {
            Name "FORWARD_BASE"
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]
            ZWrite [_ZWrite]

            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma shader_feature_local_fragment _LIGHTING_UNITY_LAMBERT _LIGHTING_UNITY_BLINN_PHONG _LIGHTING_UNITY_STANDARD _LIGHTING_UNITY_STANDARD_SPECULAR _LIGHTING_UNLIT _LIGHTING_CUSTOM
            #pragma shader_feature_local_fragment _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ _GLOSSYREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _VRCLIGHTVOLUMES_OFF _VRCLIGHTVOLUMES_ON _VRCLIGHTVOLUMES_ADDITIVE_ONLY
            #pragma shader_feature_local_fragment _VRCLIGHTVOLUMESSPECULAR_OFF _VRCLIGHTVOLUMESSPECULAR_ON _VRCLIGHTVOLUMESSPECULAR_DOMINANT_DIR
            #pragma shader_feature_local_fragment _ _LTCGI_ON

            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
