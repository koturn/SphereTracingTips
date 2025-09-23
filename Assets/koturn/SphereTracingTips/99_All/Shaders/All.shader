Shader "koturn/SphereTracingTips/99_All/All.shader"
{
    Properties
    {
        // ------------------------------------------------------------
        [Header(Ray Marching Parameters)]
        [Space(8)]

        [IntRange]
        _MaxLoop ("Maximum loop count for ForwardBase", Range(8, 1024)) = 128

        [IntRange]
        _MaxLoopForwardAdd ("Maximum loop count for ForwardAdd", Range(8, 1024)) = 64

        [IntRange]
        _MaxLoopShadowCaster ("Maximum loop count for ShadowCaster", Range(8, 1024)) = 32

        _MinMarchingLength ("Minimum marching length", Float) = 0.001

        [KeywordEnum(Use Property Value, Camera Clip, Depth Texture)]
        _ClipLengthMode ("Clip length mode", Int) = 1

        _MaxRayLength ("Maximum length of the ray", Float) = 1000.0

        _Scales ("Scale vector", Vector) = (1.0, 1.0, 1.0, 1.0)

        [KeywordEnum(Object, World)]
        _CalcSpace ("Calculation space", Int) = 0

        [KeywordEnum(Off, On, LessEqual, GreaterEqual)]
        _SVDepth ("SV_Depth ouput", Int) = 1

        [KeywordEnum(None, Simple, Max Length)]
        _AssumeInside ("Assume render target is inside object", Int) = 0

        // e.g.) 1.7321 (~= sqrt(3.0)) for default cube (1x1x1 cube).
        _MaxInsideLength ("Maximum length inside the object", Float) = 1.7321

        [KeywordEnum(Normal, Over Relax, Accelaration, Auto Relax)]
        _StepMethod ("Marching step method", Int) = 0

        _MarchingFactor ("Marching Factor", Range(0.5, 1.0)) = 1.0

        _OverRelaxFactor ("Marching Factor for Over Relaxation Sphere Tracing", Range(1.0, 2.0)) = 1.2

        _AccelarationFactor ("Coeeficient of Accelarating Sphere Tracing", Range(0.0, 1.0)) = 0.8

        _AutoRelaxFactor ("Coeeficient of Auto Step Size Relaxation", Range(0.0, 1.0)) = 0.8

        [KeywordEnum(Discard, Fixed Color)]
        _BackgroundMode ("Background mode", Int) = 0

        _BackgroundColor ("Background Color", Color) = (0.0, 0.0, 0.0, 1.0)

        [KeywordEnum(Far Clip, Mesh)]
        _BackgroundDepth ("Background depth", Int) = 0

        [KeywordEnum(None, Step, Ray Length)]
        _DebugView ("Debug view mode", Int) = 0

        [IntRange]
        _DebugStepDiv ("Divisor of number of ray steps for debug view", Range(1, 1024)) = 24

        _DebugRayLengthDiv ("Divisor of number of ray length for debug view", Range(0.01, 1000.0)) = 5.0


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

        [ToggleOff(_FORWARDADD_OFF)]
        _ForwardAdd ("ForwardAdd Pass", Int) = 1

        [KeywordEnum(Off, Front, Back)]
        _Cull ("Culling Mode", Int) = 1  // Default: Front

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


        // ------------------------------------------------------------
        [Header(Stencil Parameters)]
        [Space(8)]

        [IntRange]
        _StencilRef ("Stencil Reference Value", Range(0, 255)) = 0

        [IntRange]
        _StencilReadMask ("Stencil ReadMask Value", Range(0, 255)) = 255

        [IntRange]
        _StencilWriteMask ("Stencil WriteMask Value", Range(0, 255)) = 255

        [Enum(UnityEngine.Rendering.CompareFunction)]
        _StencilComp ("Stencil Compare Function", Int) = 8  // Default: Always

        [Enum(UnityEngine.Rendering.StencilOp)]
        _StencilPass ("Stencil Pass", Int) = 0  // Default: Keep

        [Enum(UnityEngine.Rendering.StencilOp)]
        _StencilFail ("Stencil Fail", Int) = 0  // Default: Keep

        [Enum(UnityEngine.Rendering.StencilOp)]
        _StencilZFail ("Stencil ZFail", Int) = 0  // Default: Keep
    }

    SubShader
    {
        // Not set RenderType to avoid phantom shadows when using Scalable Ambient Obscurance.
        // If you want to set the RenderType, "Transparent" is preferable.
        Tags
        {
            "Queue" = "AlphaTest"
            // "RenderType" = "Transparent"
            // "DisableBatching" = "True"
            "IgnoreProjector" = "True"
            "VRCFallback" = "Hidden"
            "LTCGI" = "_LTCGI"
        }

        Cull [_Cull]
        BlendOp [_BlendOp], [_BlendOpAlpha]
        ZTest [_ZTest]
        ZClip [_ZClip]
        Offset [_OffsetFactor], [_OffsetUnits]
        ColorMask [_ColorMask]
        AlphaToMask [_AlphaToMask]

        Stencil
        {
            Ref [_StencilRef]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
            Comp [_StencilComp]
            Pass [_StencilPass]
            Fail [_StencilFail]
            ZFail [_StencilZFail]
        }

        CGINCLUDE
        #if UNITY_VERSION >= 202030
        #    pragma target 3.0
        #    pragma target 5.0 _SVDEPTH_LESSEQUAL _SVDEPTH_GREATEREQUAL
        #else
        #    pragma target 5.0
        #endif  // UNITY_VERSION >= 202030

        #pragma multi_compile_instancing
        #pragma shader_feature_local _CALCSPACE_OBJECT _CALCSPACE_WORLD
        #pragma shader_feature_local _ASSUMEINSIDE_NONE _ASSUMEINSIDE_SIMPLE _ASSUMEINSIDE_MAX_LENGTH
        #pragma shader_feature_local _CLIPLENGTHMODE_USE_PROPERTY_VALUE _CLIPLENGTHMODE_CAMERA_CLIP _CLIPLENGTHMODE_DEPTH_TEXTURE
        #pragma shader_feature_local_fragment _SVDEPTH_OFF _SVDEPTH_ON _SVDEPTH_LESSEQUAL _SVDEPTH_GREATEREQUAL
        #pragma shader_feature_local_fragment _CULL_OFF _CULL_FRONT _CULL_BACK
        #pragma shader_feature_local_fragment _STEPMETHOD_NORMAL _STEPMETHOD_OVER_RELAX _STEPMETHOD_ACCELARATION _STEPMETHOD_AUTO_RELAX

        #if defined(_VRCLIGHTVOLUMES_ON) || defined(_VRCLIGHTVOLUMES_ADDITIVE_ONLY) || defined(_VRCLIGHTVOLUMESSPECULAR_ON) || defined(_VRCLIGHTVOLUMESSPECULAR_DOMINANT_DIR)
        #    define USE_VRCLIGHTVOLUMES
        #endif  // defined(_VRCLIGHTVOLUMES_ON) || defined(_VRCLIGHTVOLUMES_ADDITIVE_ONLY) || defined(_VRCLIGHTVOLUMESSPECULAR_ON) || defined(_VRCLIGHTVOLUMESSPECULAR_DOMINANT_DIR)

        #if defined(_SVDEPTH_ON)
        #    define DEPTH_SEMANTICS SV_Depth
        #elif defined(_SVDEPTH_LESSEQUAL)
        #    if SHADER_TARGET >= 45
        #        define DEPTH_SEMANTICS SV_DepthLessEqual
        #    else
        #        define DEPTH_SEMANTICS SV_Depth
        #    endif  // SHADER_TARGET >= 45
        #elif defined(_SVDEPTH_GREATEREQUAL)
        #    if SHADER_TARGET >= 45
        #        define DEPTH_SEMANTICS SV_DepthGreaterEqual
        #    else
        #        define DEPTH_SEMANTICS SV_Depth
        #    endif  // SHADER_TARGET >= 45
        #endif  // defined(_SVDEPTH_ON)

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


        #if defined(SHADER_API_GLCORE) \
            || defined(SHADER_API_OPENGL) \
            || defined(SHADER_API_GLES) \
            || defined(SHADER_API_GLES3)
        //! Depth of far clip plane.
        static const float kFarClipPlaneDepth = 1.0;
        #else
        //! Depth of far clip plane.
        static const float kFarClipPlaneDepth = 0.0;
        #endif


        //! Maximum loop count for ForwardBase.
        uniform int _MaxLoop;
        //! Maximum loop count for ForwardAdd.
        uniform int _MaxLoopForwardAdd;
        //! Maximum loop count for ShadowCaster.
        uniform int _MaxLoopShadowCaster;
        //! Minimum marching length.
        uniform float _MinMarchingLength;
        //! Maximum length of the ray.
        uniform float _MaxRayLength;
        //! Maximum length inside the object.
        uniform float _MaxInsideLength;
        //! Marching Factor.
        uniform float _MarchingFactor;
        //! Marching Factor for Over Relaxation Sphere Tracing.
        uniform float _OverRelaxFactor;
        //! Coeeficient of Accelarating Sphere Tracing.
        uniform float _AccelarationFactor;
        //! Coeeficient of Auto Step Size Relaxation.
        uniform float _AutoRelaxFactor;
        //! Scale vector.
        uniform float3 _Scales;
        //! Specular power.
        uniform float _SpecPower;
        //! Value of smoothness.
        uniform half _Glossiness;
        //! Value of Metallic.
        uniform half _Metallic;
        //! Color of the objects.
        uniform half4 _Color;
        //! Background color.
        uniform half4 _BackgroundColor;
        //! Divisor of number of ray steps for debug view.
        uniform float _DebugStepDiv;
        //! Divisor of number of ray length for debug view.
        uniform float _DebugRayLengthDiv;


        #if !defined(UNITY_LIGHTING_COMMON_INCLUDED)
        //! Color of light.
        uniform fixed4 _LightColor0;
        #endif  // !defined(UNITY_LIGHTING_COMMON_INCLUDED)
        #if !defined(UNITY_LIGHTING_COMMON_INCLUDED) && !defined(UNITY_STANDARD_SHADOW_INCLUDED)
        //! Specular color.
        uniform half4 _SpecColor;
        #endif  // !defined(UNITY_LIGHTING_COMMON_INCLUDED) && !defined(UNITY_STANDARD_SHADOW_INCLUDED)

        UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

        #if defined(_VRCLIGHTVOLUMES_ON) || defined(_VRCLIGHTVOLUMES_ADDITIVE_ONLY) || defined(_VRCLIGHTVOLUMESSPECULAR_ON) || defined(_VRCLIGHTVOLUMESSPECULAR_DOMINANT_DIR)
        //! Are Light Volumes enabled on scene?
        uniform float _UdonLightVolumeEnabled;
        //! All volumes count in scene
        uniform float _UdonLightVolumeCount;
        #endif  // defined(_VRCLIGHTVOLUMES_ON) || defined(_VRCLIGHTVOLUMES_ADDITIVE_ONLY) || defined(_VRCLIGHTVOLUMESSPECULAR_ON) || defined(_VRCLIGHTVOLUMESSPECULAR_DOMINANT_DIR)


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
        #if defined(_CALCSPACE_WORLD) || defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH) || defined(_BACKGROUNDMODE_FIXED_COLOR)
            //! Object/World space position of the fragment.
            float3 fragPos : TEXCOORD0;
        #else
            //! Unnormalized ray direction in object space.
            float3 rayDirVec : TEXCOORD0;
        #endif  // defined(_CALCSPACE_WORLD) || defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH) || defined(_BACKGROUNDMODE_FIXED_COLOR)
        #if !defined(_CALCSPACE_WORLD)
            //! Camera position in object space. (for pre-calulation on vertex shader)
            nointerpolation float3 cameraPos : TEXCOORD1;
        #endif  // !defined(_CALCSPACE_WORLD)
        #if defined(_CLIPLENGTHMODE_DEPTH_TEXTURE)
            float4 screenPos : TEXCOORD2;
        #endif  // defined(_CLIPLENGTHMODE_DEPTH_TEXTURE)
            //! Members abourt lighting coordinates, _LightCoord and _ShadowCoord.
            UNITY_LIGHTING_COORDS(3, 4)
        #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
            //! Lightmap and Dynamic Lightmap coordinate.
            float4 lmap: TEXCOORD5;
        #endif  // defined(LIGHTMAP_ON)
            //! Instance ID for single pass instanced rendering, instanceID.
            UNITY_VERTEX_INPUT_INSTANCE_ID
            //! Stereo target eye index for single pass instanced rendering, stereoTargetEyeIndex.
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
        #if defined(DEPTH_SEMANTICS) && (!defined(UNITY_PASS_SHADOWCASTER) || !defined(SHADOWS_CUBE) || defined(SHADOWS_CUBE_IN_DEPTH_TEX))
            //! Depth of the pixel.
            float depth : DEPTH_SEMANTICS;
        #endif  // defined(DEPTH_SEMANTICS) && (!defined(UNITY_PASS_SHADOWCASTER) || !defined(SHADOWS_CUBE) || defined(SHADOWS_CUBE_IN_DEPTH_TEX))
        };

        /*!
         * @brief Ray parameters for Raymarching.
         */
        struct rayparam
        {
            //! Object/World space ray origin.
            float3 rayOrigin;
            //! Object/World space ray direction.
            float3 rayDir;
            //! Object/World space initial ray length.
            float initRayLength;
            //! Object/World space maximum ray length.
            float maxRayLength;
        };

        /*!
         * @brief Output of rayMarch().
         * @see rayMarch
         */
        struct rmout
        {
            //! Length of the ray.
            float rayLength;
            //! Number of ray steps.
            int rayStep;
            //! A flag whether the ray collided with an object or not.
            bool isHit;
        };


        #if defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES) || defined(SHADER_API_D3D9)
        typedef fixed face_t;
        #    define FACE_SEMANTICS VFACE
        #else
        typedef bool face_t;
        #    define FACE_SEMANTICS SV_IsFrontFace
        #endif  // defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES) || defined(SHADER_API_D3D9)


        rayparam calcRayParam(v2f fi, float maxRayLength, float maxInsideLength, bool isFace);
        rmout rayMarch(rayparam rp);
        float map(float3 p);
        float sdSphere(float3 p, float r);
        float3 calcNormal(float3 p);
        float getDepth(float4 clipPos);
        half4 calcLighting(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap, half3 ambient);
        half4 calcLightingUnity(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap, half3 ambient);
        half4 calcLightingCustom(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap, half3 ambient);
        UnityGI getGI(float3 worldPos, half atten);
        UnityGIInput getGIInput(UnityLight light, float3 worldPos, float3 worldNormal, float3 worldViewDir, half atten, float4 lmap, half3 ambient);
        bool isFacing(face_t facing);
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
            const float3 vertPos = v.vertex.xyz;
            o.cameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz;
        #    if defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH) || defined(_BACKGROUNDMODE_FIXED_COLOR)
            o.fragPos = vertPos;
        #    else
            o.rayDirVec = vertPos - o.cameraPos;
        #    endif  // defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH) || defined(_BACKGROUNDMODE_FIXED_COLOR)
        #endif  // defined(_CALCSPACE_WORLD)

        #if defined(LIGHTMAP_ON)
            o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        #endif  // defined(LIGHTMAP_ON)
        #if defined(DYNAMICLIGHTMAP_ON)
            o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
        #endif  // defined(DYNAMICLIGHTMAP_ON)

            UNITY_TRANSFER_LIGHTING(o, v.texcoord1);

            o.pos = UnityObjectToClipPos(v.vertex);
        #if defined(_CLIPLENGTHMODE_DEPTH_TEXTURE)
            o.screenPos = ComputeNonStereoScreenPos(o.pos);
            COMPUTE_EYEDEPTH(o.screenPos.z);
        #endif  // defined(_CLIPLENGTHMODE_DEPTH_TEXTURE)

            return o;
        }

        #if !defined(_CULL_FRONT) && !defined(_CULL_BACK) && (defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH))
        /*!
         * @brief Fragment shader function.
         * @param [in] fi  Input data from vertex shader.
         * @param [in] facing  Facing parameter.
         * @return Color and depth of fragment.
         */
        fout frag(v2f fi, face_t facing : FACE_SEMANTICS)
        #else
        /*!
         * @brief Fragment shader function.
         * @param [in] fi  Input data from vertex shader.
         * @return Color and depth of fragment.
         */
        fout frag(v2f fi)
        #endif  // defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH)
        {
            UNITY_SETUP_INSTANCE_ID(fi);
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(fi);

        #if defined(_CULL_FRONT)
            static const bool isFace = false;
        #elif defined(_CULL_BACK)
            static const bool isFace = true;
        #elif defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH)
            const bool isFace = isFacing(facing);
        #else
            static const bool isFace = true;  // Unused.
        #endif  // defined(_CULL_FRONT)

            const rayparam rp = calcRayParam(fi, _MaxRayLength, _MaxInsideLength, isFace);
            const rmout ro = rayMarch(rp);
        #if !defined(_DEBUGVIEW_STEP) && !defined(_DEBUGVIEW_RAY_LENGTH)
            if (!ro.isHit) {
        #    if defined(_BACKGROUNDMODE_FIXED_COLOR)
                fout fo;
        #        if defined(_CALCSPACE_WORLD)
                const float4 clipPos = UnityWorldToClipPos(fi.fragPos);
        #        else
                const float4 clipPos = UnityObjectToClipPos(fi.fragPos);
        #        endif  // defined(_CALCSPACE_WORLD)
                fo.color = _BackgroundColor;
                UNITY_APPLY_FOG(clipPos.z, color);
        #        if defined(DEPTH_SEMANTICS)
        #            if defined(_BACKGROUNDDEPTH_MESH)
                fo.depth = getDepth(clipPos);
        #            else
                fo.depth = kFarClipPlaneDepth;
        #            endif  // defined(_BACKGROUNDDEPTH_MESH)
        #        endif  // defined(DEPTH_SEMANTICS)
                return fo;
        #    else
                discard;
        #    endif  // defined(_BACKGROUNDMODE_FIXED_COLOR)
            }
        #endif  // !defined(_DEBUGVIEW_STEP) && !defined(_DEBUGVIEW_RAY_LENGTH)

        #if defined(_CALCSPACE_WORLD)
            const float3 worldFinalPos = rp.rayOrigin + rp.rayDir * ro.rayLength;
            const float3 worldNormal = calcNormal(worldFinalPos);
        #else
            const float3 localFinalPos = rp.rayOrigin + rp.rayDir * ro.rayLength;
            const float3 worldFinalPos = mul(unity_ObjectToWorld, float4(localFinalPos, 1.0)).xyz;
            const float3 localNormal = calcNormal(localFinalPos);
            const float3 worldNormal = UnityObjectToWorldNormal(localNormal);
        #endif  // defined(_CALCSPACE_WORLD)

        #if defined(LIGHTMAP_ON)
        #    if defined(DYNAMICLIGHTMAP_ON)
            const float4 lmap = fi.lmap;
        #    else
            const float4 lmap = float4(fi.lmap.xy, 0.0, 0.0);
        #    endif  // defined(DYNAMICLIGHTMAP_ON)
        #elif UNITY_SHOULD_SAMPLE_SH
            const float4 lmap = float4(0.0, 0.0, 0.0, 0.0);
        #else
            const float4 lmap = float4(0.0, 0.0, 0.0, 0.0);
        #endif  // defined(LIGHTMAP_ON)

            UNITY_LIGHT_ATTENUATION(atten, fi, worldFinalPos);

            half4 color = calcLighting(
                _Color,
                worldFinalPos,
                worldNormal,
                atten,
                lmap,
                half3(0.0, 0.0, 0.0));

            const float4 clipPos = UnityWorldToClipPos(worldFinalPos);

            UNITY_APPLY_FOG(clipPos.z, color);

            fout fo;
        #if defined(_DEBUGVIEW_STEP)
            fo.color = float4((ro.rayStep / _DebugStepDiv).xxx, 1.0);
        #elif defined(_DEBUGVIEW_RAY_LENGTH)
            fo.color = float4((ro.rayLength / _DebugRayLengthDiv).xxx, 1.0);
        #else
            fo.color = color;
        #endif  // defined(_DEBUGVIEW_STEP)
        #if defined(DEPTH_SEMANTICS)
            fo.depth = getDepth(clipPos);
        #endif  // defined(DEPTH_SEMANTICS)

            return fo;
        }

        /*!
         * Calculate raymarching parameters for ForwardBase/ForwardAdd pass.
         * @param [in] fi  Input data of fragment shader function.
         * @param [in] maxRayLength  Maximum ray length.
         * @param [in] maxInsideLength  Maximum length inside an object.
         * @param [in] isFace  A flag whether the surface is facing the camera or facing away from the camera.
         * @return Ray parameters.
         */
        rayparam calcRayParam(v2f fi, float maxRayLength, float maxInsideLength, bool isFace)
        {
            rayparam rp;

        #if defined(_CALCSPACE_WORLD)
            rp.rayOrigin = _WorldSpaceCameraPos;
            const float3 rayDirVec = fi.fragPos - _WorldSpaceCameraPos;
        #else
            rp.rayOrigin = fi.cameraPos;
        #    if defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH) || defined(_BACKGROUNDMODE_FIXED_COLOR)
            const float3 rayDirVec = fi.fragPos - fi.cameraPos;
        #    else
            const float3 rayDirVec = fi.rayDirVec;
        #    endif  // defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH) || defined(_BACKGROUNDMODE_FIXED_COLOR)
        #endif  // defined(_CALCSPACE_WORLD)
            rp.rayDir = normalize(rayDirVec);

        #if !defined(_CLIPLENGTHMODE_CAMERA_CLIP) && !defined(_CLIPLENGTHMODE_DEPTH_TEXTURE)
            const float2 clipRayLengths = float2(0.0, maxRayLength);
        #else
            // `rdv` is cos(x) * y, where x is angle between camera forward direction and ray direction
            // and y is local scale factor.
        #    if defined(_CALCSPACE_WORLD)
            const float rdv = dot(rp.rayDir, -UNITY_MATRIX_V[2].xyz);
        #    else
            const float rdv = dot(mul((float3x3)unity_ObjectToWorld, rp.rayDir), -UNITY_MATRIX_V[2].xyz);
        #    endif  // defined(_CALCSPACE_WORLD)
        #    if defined(_CLIPLENGTHMODE_CAMERA_CLIP)
            const float2 linearDepths = _ProjectionParams.yz;
        #    else
            const float2 linearDepths = float2(_ProjectionParams.y, LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, fi.screenPos)));
        #    endif  // defined(_CLIPLENGTHMODE_CAMERA_CLIP)
            // x: Length to near clip plane
            // y: Length to far clip plane
            float2 clipRayLengths = linearDepths / rdv;
        #endif

        #if defined(_ASSUMEINSIDE_MAX_LENGTH)
            // Facing | Start position of the ray                        | Max ray length
            // -------|--------------------------------------------------|-----------------------------------------------------------
            // Front  | Surface of the frontface mesh                    | Distance from camera to backface mesh + `_MaxInsideLength`
            // Back   | Between Camera and surface of the frontface mesh | Distance from camera to backface mesh
        #    if defined(_CALCSPACE_WORLD)
            maxInsideLength = maxInsideLength / length(mul((float3x3)unity_WorldToObject, rp.rayDir));
        #    endif  // defined(_CALCSPACE_WORLD)
            const float rayDirVecLength = length(rayDirVec);
            const float3 startPos = fi.fragPos - (isFace ? float3(0.0, 0.0, 0.0) : min(rayDirVecLength, maxInsideLength) * rp.rayDir);
            rp.initRayLength = max(clipRayLengths.x, length(startPos - rp.rayOrigin));
            rp.maxRayLength = min(clipRayLengths.y, rayDirVecLength + (isFace ? maxInsideLength : 0.0));
        #elif defined(_ASSUMEINSIDE_SIMPLE)
            // Facing | Start position of the ray | Max ray length
            // -------|---------------------------|-----------------------------
            // Front  | Surface of the mesh       | `clipRayLengths.y`
            // Back   | Camera                    | Distance from camera to mesh
            rp.initRayLength = isFace ? max(clipRayLengths.x, length(fi.fragPos - rp.rayOrigin)) : clipRayLengths.x;
            rp.maxRayLength = isFace ? clipRayLengths.y : length(rayDirVec);
        #else
            rp.initRayLength = clipRayLengths.x;
            rp.maxRayLength = clipRayLengths.y;
        #endif  // defined(_ASSUMEINSIDE_MAX_LENGTH)

            return rp;
        }

        /*!
         * @brief Execute ray marching.
         *
         * @param [in] rp  Ray parameters.
         * @return Result of the ray marching.
         */
        rmout rayMarch(rayparam rp)
        {
        #if defined(UNITY_PASS_FORWARDBASE)
            const int maxLoop = _MaxLoop;
        #elif defined(UNITY_PASS_FORWARDADD)
            const int maxLoop = _MaxLoopForwardAdd;
        #elif defined(UNITY_PASS_DEFERRED)
            const int maxLoop = _MaxLoop;
        #elif defined(UNITY_PASS_SHADOWCASTER)
            const int maxLoop = _MaxLoopShadowCaster;
        #endif  // defined(UNITY_PASS_FORWARDBASE)
            const float3 rcpScales = rcp(_Scales);
            const float dcRate = rsqrt(dot(rp.rayDir * rcpScales, rp.rayDir * rcpScales));
            const float minMarchingLength = _MinMarchingLength * dcRate;
            const float maxRayLength = rp.maxRayLength * dcRate;

            rmout ro;
            ro.rayLength = rp.initRayLength;
            ro.isHit = false;

        #if defined(_STEPMETHOD_OVER_RELAX)
            // https://diglib.eg.org/items/8ea5fa60-fe2f-4fef-8fd0-3783cb3200f0
            float r = asfloat(0x7f800000);  // +inf
            float d = 0.0;
            for (ro.rayStep = 0; abs(r) >= minMarchingLength && ro.rayLength < maxRayLength && ro.rayStep < maxLoop; ro.rayStep++) {
                const float nextRayLength = ro.rayLength + d;
                const float nextR = map((rp.rayOrigin + rp.rayDir * nextRayLength) * rcpScales) * dcRate;
                if (d <= r + abs(nextR)) {
                    d = _OverRelaxFactor * nextR;
                    ro.rayLength = nextRayLength;
                    r = nextR;
                } else {
                    d = r;
                }
            }
            ro.isHit = abs(r) < minMarchingLength;
        #elif defined(_STEPMETHOD_ACCELARATION)
            // https://www.researchgate.net/publication/331547302_Accelerating_Sphere_Tracing
            // https://www.researchgate.net/publication/329152815_Accelerating_Sphere_Tracing
            float r = map((rp.rayOrigin + rp.rayDir * ro.rayLength) * rcpScales) * dcRate;
            float d = r;

            for (ro.rayStep = 1; r >= minMarchingLength && ro.rayLength + r < maxRayLength && ro.rayStep < maxLoop; ro.rayStep++) {
                const float nextRayLength = ro.rayLength + d;
                const float nextR = map((rp.rayOrigin + rp.rayDir * nextRayLength) * rcpScales) * dcRate;
                if (d <= r + abs(nextR)) {
                    const float deltaR = nextR - r;
                    const float2 zr = d.xx + deltaR * float2(1.0, -1.0);
                    d = nextR + _AccelarationFactor * nextR * (zr.x / zr.y);
                    ro.rayLength = nextRayLength;
                    r = nextR;
                } else {
                    d = r;
                }
            }
            ro.isHit = abs(r) < minMarchingLength;
        #elif defined(_STEPMETHOD_AUTO_RELAX)
            // https://www.researchgate.net/publication/370902411_Automatic_Step_Size_Relaxation_in_Sphere_Tracing
            float r = map((rp.rayOrigin + rp.rayDir * ro.rayLength) * rcpScales) * dcRate;
            float d = r;
            float m = -1.0;

            for (ro.rayStep = 1; r >= minMarchingLength && ro.rayLength + r < maxRayLength && ro.rayStep < maxLoop; ro.rayStep++) {
                const float nextRayLength = ro.rayLength + d;
                const float nextR = map((rp.rayOrigin + rp.rayDir * nextRayLength) * rcpScales) * dcRate;
                if (d <= r + abs(nextR)) {
                    m = lerp(m, (nextR - r) / d, _AutoRelaxFactor);
                    ro.rayLength = nextRayLength;
                    r = nextR;
                } else {
                    m = -1.0;
                }
                d = 2.0 * r / (1.0 - m);
            }
            ro.isHit = r < minMarchingLength;
        #else  // Assume: _STEPMETHOD_NORMAL
            float d = asfloat(0x7f800000);  // +inf
            for (ro.rayStep = 0; d >= minMarchingLength && ro.rayLength < maxRayLength && ro.rayStep < maxLoop; ro.rayStep++) {
                d = map((rp.rayOrigin + rp.rayDir * ro.rayLength) * rcpScales) * dcRate;
                ro.rayLength += d;
            }
            ro.isHit = d < minMarchingLength;
        #endif

            return ro;
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
         * Calculate lighting.
         * @param [in] color  Base color.
         * @param [in] worldPos  World coordinate.
         * @param [in] worldNormal  Normal in world space.
         * @param [in] atten  Light attenuation.
         * @param [in] lmap  Light map parameters.
         * @param [in] ambient  Ambient light.
         * @return Lighting applied color.
         */
        half4 calcLighting(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap, half3 ambient)
        {
        #if defined(_LIGHTING_CUSTOM)
            return calcLightingCustom(color, worldPos, worldNormal, atten, lmap, ambient);
        #elif defined(_LIGHTING_UNITY_LAMBERT) \
            || defined(_LIGHTING_UNITY_BLINN_PHONG) \
            || defined(_LIGHTING_UNITY_STANDARD) \
            || defined(_LIGHTING_UNITY_STANDARD_SPECULAR)
            return calcLightingUnity(color, worldPos, worldNormal, atten, lmap, ambient);
        #else
            // assume _LIGHTING_UNLIT
            return color;
        #endif  // defined(_LIGHTING_CUSTOM)
        }


        /*!
         * Calculate lighting with lighting method on Unity Surface Shaders.
         * @param [in] color  Base color.
         * @param [in] worldPos  World coordinate.
         * @param [in] worldNormal  Normal in world space.
         * @param [in] atten  Light attenuation.
         * @param [in] lmap  Light map parameters.
         * @param [in] ambient  Ambient light.
         * @return Lighting applied color.
         */
        half4 calcLightingUnity(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap, half3 ambient)
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
        #    if !defined(LIGHTMAP_ON) && !defined(DYNAMICLIGHTMAP_ON)
            lmap = float4(0.0, 0.0, 0.0, 0.0);
        #    endif  // !defined(LIGHTMAP_ON) && !defined(DYNAMICLIGHTMAP_ON)
            UnityGIInput giInput = getGIInput(gi.light, worldPos, worldNormal, worldViewDir, atten, lmap, ambient);
            LightingUnity_GI(so, giInput, gi);
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
         * @param [in] lmap  Light map parameters.
         * @param [in] ambient  Ambient light.
         * @return Lighting applied color.
         */
        half4 calcLightingCustom(half4 color, float3 worldPos, float3 worldNormal, half atten, /* unused */ float4 lmap, half3 ambient)
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

        #if !defined(_LIGHTING_UNITY_LAMBERT) && !defined(_LIGHTING_UNITY_BLINN_PHONG)
            giInput.probeHDR[0] = unity_SpecCube0_HDR;
            giInput.probeHDR[1] = unity_SpecCube1_HDR;
        #    if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
            giInput.boxMin[0] = unity_SpecCube0_BoxMin;
        #    endif  // defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
        #    if defined(UNITY_SPECCUBE_BOX_PROJECTION)
            giInput.boxMax[0] = unity_SpecCube0_BoxMax;
            giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
            giInput.boxMax[1] = unity_SpecCube1_BoxMax;
            giInput.boxMin[1] = unity_SpecCube1_BoxMin;
            giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
        #    endif  // defined(UNITY_SPECCUBE_BOX_PROJECTION)
        #endif  // !defined(_LIGHTING_UNITY_LAMBERT) && !defined(_LIGHTING_UNITY_BLINN_PHONG)

            return giInput;
        }

        /*!
         * @brief Identify whether surface is facing the camera or facing away from the camera.
         * @param [in] facing  Facing variable (fixed or bool).
         * @return True if surface facing the camera, otherwise false.
         */
        bool isFacing(face_t facing)
        {
        #if defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES) || defined(SHADER_API_D3D9)
            return facing >= 0.0;
        #else
            return facing;
        #endif  // defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES) || defined(SHADER_API_D3D9)
        }


        #if defined(USE_VRCLIGHTVOLUMES)
        /*!
         * @brief Calculate ambient of VRC Light Volumes.
         * @param [in] albedo  Albedo.
         * @param [in] worldPos  World coordinate.
         * @param [in] worldNormal  Normal in world space.
         * @param [in] worldViewDir  View direction in world space.
         * @param [in] glossiness  Smoothness.
         * @param [in] metallic  Metallic.
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
            #pragma shader_feature_local_fragment _BACKGROUNDMODE_DISCARD _BACKGROUNDMODE_FIXED_COLOR
            #pragma shader_feature_local_fragment _BACKGROUNDDEPTH_FAR _BACKGROUNDDEPTH_CLIP _BACKGROUNDDEPTH_MESH
            #pragma shader_feature_local_fragment _DEBUGVIEW_NONE _DEBUGVIEW_STEP _DEBUGVIEW_RAY_LENGTH
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

        Pass
        {
            Name "FORWARD_ADD"
            Tags
            {
                "LightMode" = "ForwardAdd"
            }

            Blend [_SrcBlend] One
            ZWrite Off

            CGPROGRAM
            // #pragma multi_compile_fwdadd
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma shader_feature_local _ _FORWARDADD_OFF
            #pragma shader_feature_local_fragment _BACKGROUNDMODE_DISCARD _BACKGROUNDMODE_FIXED_COLOR
            #pragma shader_feature_local_fragment _BACKGROUNDDEPTH_FAR _BACKGROUNDDEPTH_CLIP _BACKGROUNDDEPTH_MESH
            #pragma shader_feature_local_fragment _DEBUGVIEW_NONE _DEBUGVIEW_STEP _DEBUGVIEW_RAY_LENGTH
            #pragma shader_feature_local_fragment _LIGHTING_UNITY_LAMBERT _LIGHTING_UNITY_BLINN_PHONG _LIGHTING_UNITY_STANDARD _LIGHTING_UNITY_STANDARD_SPECULAR _LIGHTING_UNLIT _LIGHTING_CUSTOM
            #pragma shader_feature_local_fragment _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ _GLOSSYREFLECTIONS_OFF

            #pragma vertex vertForwardAdd
            #pragma fragment fragForwardAdd

            #if defined(_FORWARDADD_OFF) || defined(_DEBUGVIEW_STEP) || defined(_DEBUGVIEW_RAY_LENGTH) || defined(_LIGHTING_UNLIT)
            /*!
             * @brief Vertex shader function for ForwardAdd pass.
             *
             * This function outputs NaN vertice to skip fragment shader.
             *
             * @return NaN vertex.
             */
            float4 vertForwardAdd() : SV_POSITION
            {
                return asfloat(0x7fc00000).xxxx;  // qNaN
            }

            /*!
             * @brief Fragment shader function for ForwardAdd pass.
             *
             * This function will not be execute because vertForwardAdd outputs NaN vertices,
             * and the vertices will be removed by view frustum culling.
             *
             * @return (0.0, 0.0, 0.0, 0.0).
             */
            half4 fragForwardAdd() : SV_Target
            {
                return half4(0.0, 0.0, 0.0, 0.0);
            }
            #else

            /*!
             * @brief Vertex shader function for ForwardAdd pass.
             * @param [in] v  Input data.
             * @return Interpolation source data for fragment shader function, fragForwardAdd().
             * @see fragForwardAdd
             */
            v2f vertForwardAdd(appdata v)
            {
                return vert(v);
            }

            #    if !defined(_CULL_FRONT) && !defined(_CULL_BACK) && (defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH))
            /*!
             * @brief Fragment shader function.
             * @param [in] fi  Input data from vertex shader.
             * @param [in] facing  Facing parameter.
             * @return Color and depth of fragment.
             */
            fout fragForwardAdd(v2f fi, face_t facing : FACE_SEMANTICS)
            {
                return frag(fi, facing);
            }
            #    else
            /*!
             * @brief Fragment shader function.
             * @param [in] fi  Input data from vertex shader.
             * @return Color and depth of fragment.
             */
            fout fragForwardAdd(v2f fi)
            {
                return frag(fi);
            }
            #    endif  // defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH)
            #endif  // defined(_FORWARDADD_OFF) || defined(_DEBUGVIEW_STEP) || defined(_DEBUGVIEW_RAY_LENGTH) || defined(_LIGHTING_UNLIT)
            ENDCG
        }

        Pass
        {
            Name "DEFERRED"
            Tags
            {
                "LightMode" = "Deferred"
            }

            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]
            ZWrite [_ZWrite]

            CGPROGRAM
            #pragma exclude_renderers nomrt
            #pragma multi_compile_prepassfinal
            #pragma shader_feature_local_fragment _BACKGROUNDMODE_DISCARD _BACKGROUNDMODE_FIXED_COLOR
            #pragma shader_feature_local_fragment _BACKGROUNDDEPTH_FAR _BACKGROUNDDEPTH_CLIP _BACKGROUNDDEPTH_MESH
            #pragma shader_feature_local_fragment _DEBUGVIEW_NONE _DEBUGVIEW_STEP _DEBUGVIEW_RAY_LENGTH
            #pragma shader_feature_local_fragment _LIGHTING_UNITY_LAMBERT _LIGHTING_UNITY_BLINN_PHONG _LIGHTING_UNITY_STANDARD _LIGHTING_UNITY_STANDARD_SPECULAR _LIGHTING_UNLIT _LIGHTING_CUSTOM

            #pragma vertex vert
            #pragma fragment fragDeferred

            /*!
             * @brief G-Buffer data which is output of fragDeferred.
             * @see fragDeferred
             */
            struct GBuffer
            {
                //! Diffuse and occlustion. (rgb: diffuse, a: occlusion)
                half4 diffuse : SV_Target0;
                //! Specular and smoothness. (rgb: specular, a: smoothness)
                half4 specular : SV_Target1;
                //! Normal. (rgb: normal, a: unused)
                half4 normal : SV_Target2;
                //! Emission. (rgb: emission, a: unused)
                half4 emission : SV_Target3;
            #if defined(DEPTH_SEMANTICS)
                //! Depth of the pixel.
                float depth : DEPTH_SEMANTICS;
            #endif  // defined(DEPTH_SEMANTICS)
            };


            half4 calcLightingDeferred(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap, half3 ambient, out half4 diffuse, out half4 specular, out half4 normal);
            half4 calcLightingUnityDeferred(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap, half3 ambient, out half4 diffuse, out half4 specular, out half4 normal);
            half4 calcLightingCustomDeferred(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap, half3 ambient, out half4 diffuse, out half4 specular, out half4 normal);


            #if !defined(_CULL_FRONT) && !defined(_CULL_BACK) && (defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH))
            /*!
            * @brief Fragment shader function.
            * @param [in] fi  Input data from vertex shader.
            * @param [in] facing  Facing parameter.
            * @return G-Buffer data.
            */
            GBuffer fragDeferred(v2f fi, face_t facing : FACE_SEMANTICS)
            #else
            /*!
            * @brief Fragment shader function.
            * @param [in] fi  Input data from vertex shader.
            * @return G-Buffer data.
            */
            GBuffer fragDeferred(v2f fi)
            #endif  // defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH)
            {
                UNITY_SETUP_INSTANCE_ID(fi);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(fi);

            #if defined(_CULL_FRONT)
                static const bool isFace = false;
            #elif defined(_CULL_BACK)
                static const bool isFace = true;
            #elif defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH)
                const bool isFace = isFacing(facing);
            #else
                static const bool isFace = true;  // Unused.
            #endif  // defined(_CULL_FRONT)

                const rayparam rp = calcRayParam(fi, _MaxRayLength, _MaxInsideLength, isFace);
                const rmout ro = rayMarch(rp);
            #if !defined(_DEBUGVIEW_STEP) && !defined(_DEBUGVIEW_RAY_LENGTH)
                if (!ro.isHit) {
            #    if defined(_BACKGROUNDMODE_FIXED_COLOR)
                    GBuffer gb;
                    UNITY_INITIALIZE_OUTPUT(GBuffer, gb);
            #        if defined(_CALCSPACE_WORLD)
                    const float4 clipPos = UnityWorldToClipPos(fi.fragPos);
            #        else
                    const float4 clipPos = UnityObjectToClipPos(fi.fragPos);
            #        endif  // defined(_CALCSPACE_WORLD)
                    gb.emission.rgb = _BackgroundColor.rgb;
                    gb.diffuse.a = 1.0;
                    // gb.normal.rgb = (0.0).xxx;
            #        if defined(DEPTH_SEMANTICS)
            #            if defined(_BACKGROUNDDEPTH_MESH)
                    gb.depth = getDepth(clipPos);
            #            else
                    gb.depth = kFarClipPlaneDepth;
            #            endif  // defined(_BACKGROUNDDEPTH_MESH)
            #        endif  // defined(DEPTH_SEMANTICS)
                    return gb;
            #    else
                    discard;
            #    endif  // defined(_BACKGROUNDMODE_FIXED_COLOR)
                }
            #endif  // !defined(_DEBUGVIEW_STEP) && !defined(_DEBUGVIEW_RAY_LENGTH)

            #if defined(_CALCSPACE_WORLD)
                const float3 worldFinalPos = rp.rayOrigin + rp.rayDir * ro.rayLength;
                const float3 worldNormal = calcNormal(worldFinalPos);
            #else
                const float3 localFinalPos = rp.rayOrigin + rp.rayDir * ro.rayLength;
                const float3 worldFinalPos = mul(unity_ObjectToWorld, float4(localFinalPos, 1.0)).xyz;
                const float3 worldNormal = UnityObjectToWorldNormal(calcNormal(localFinalPos));
            #endif  // defined(_CALCSPACE_WORLD)

            #if defined(LIGHTMAP_ON)
            #    if defined(DYNAMICLIGHTMAP_ON)
                const float4 lmap = fi.lmap;
            #    else
                const float4 lmap = float4(fi.lmap.xy, 0.0, 0.0);
            #    endif  // defined(DYNAMICLIGHTMAP_ON)
            #elif UNITY_SHOULD_SAMPLE_SH
                const float4 lmap = float4(0.0, 0.0, 0.0, 0.0);
            #else
                const float4 lmap = float4(0.0, 0.0, 0.0, 0.0);
            #endif  // defined(LIGHTMAP_ON)

                GBuffer gb;
                UNITY_INITIALIZE_OUTPUT(GBuffer, gb);
            #if defined(_DEBUGVIEW_STEP)
                gb.emission = float4((ro.rayStep / _DebugStepDiv).xxx, 1.0);
            #elif defined(_DEBUGVIEW_RAY_LENGTH)
                UNITY_INITIALIZE_OUTPUT(GBuffer, gb);
                gb.emission = float4((ro.rayLength / _DebugRayLengthDiv).xxx, 1.0);
            #else
                gb.emission = calcLightingDeferred(
                    _Color,
                    worldFinalPos,
                    worldNormal,
                    1.0,
                    lmap,
                    half3(0.0, 0.0, 0.0),
                    /* out */ gb.diffuse,
                    /* out */ gb.specular,
                    /* out */ gb.normal);
            #endif  // defined(_DEBUGVIEW_STEP)

            #if defined(DEPTH_SEMANTICS)
                const float4 clipPos = UnityWorldToClipPos(worldFinalPos);
                gb.depth = getDepth(clipPos);
            #endif  // defined(DEPTH_SEMANTICS)

                return gb;
            }

            /*!
             * Calculate lighting.
             * @param [in] color  Base color.
             * @param [in] worldPos  World coordinate.
             * @param [in] worldNormal  Normal in world space.
             * @param [in] atten  Light attenuation.
             * @param [in] lmap  Light map parameters.
             * @param [in] ambient  Ambient light.
             * @param [out] diffuse  Diffuse and occulusion. (rgb: diffuse, a: occlusion)
             * @param [out] specular  Specular and smoothness. (rgb: specular, a: smoothness)
             * @param [out] normal  Encoded normal. (rgb: normal, a: unused)
             * @return Emission color.
             */
            half4 calcLightingDeferred(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap, half3 ambient, out half4 diffuse, out half4 specular, out half4 normal)
            {
            #if defined(_LIGHTING_CUSTOM)
                return calcLightingCustomDeferred(color, worldPos, worldNormal, atten, lmap, ambient, /* out */ diffuse, /* out */ specular, /* out */ normal);
            #elif defined(_LIGHTING_UNITY_LAMBERT) \
                || defined(_LIGHTING_UNITY_BLINN_PHONG) \
                || defined(_LIGHTING_UNITY_STANDARD) \
                || defined(_LIGHTING_UNITY_STANDARD_SPECULAR)
                return calcLightingUnityDeferred(color, worldPos, worldNormal, atten, lmap, ambient, /* out */ diffuse, /* out */ specular, /* out */ normal);
            #else
                // assume _LIGHTING_UNLIT
                // diffuse = half4(color.rgb, 1.0);
                diffuse = half4(0.0, 0.0, 0.0, 1.0);
                specular = half4(0.0, 0.0, 0.0, 0.0);
                normal = half4(worldNormal * 0.5 + 0.5, 1.0);
                // normal = half4(0.0, 0.0, 0.0, 1.0);
                // return half4(0.0, 0.0, 0.0, 0.0);
                return half4(color.rgb, 0.0);
            #endif  // defined(_LIGHTING_CUSTOM)
            }

            /*!
             * Calculate lighting with lighting method on Unity Surface Shaders.
             * @param [in] color  Base color.
             * @param [in] worldPos  World coordinate.
             * @param [in] worldNormal  Normal in world space.
             * @param [in] atten  Light attenuation.
             * @param [in] lmap  Light map parameters.
             * @param [in] ambient  Ambient light.
             * @param [out] diffuse  Diffuse and occulusion. (rgb: diffuse, a: occlusion)
             * @param [out] specular  Specular and smoothness. (rgb: specular, a: smoothness)
             * @param [out] normal  Encoded normal. (rgb: normal, a: unused)
             * @return Emission color.
             */
            half4 calcLightingUnityDeferred(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap, half3 ambient, out half4 diffuse, out half4 specular, out half4 normal)
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
            #    define LightingUnity_Deferred(so, worldViewDir, gi, diffuse, specular, normal) LightingStandard_Deferred(so, worldViewDir, gi, diffuse, specular, normal)
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
            #    define LightingUnity_Deferred(so, worldViewDir, gi, diffuse, specular, normal) LightingStandardSpecular_Deferred(so, worldViewDir, gi, diffuse, specular, normal)
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
                so.Emission = half3(0.0, 0.0, 0.0);
            #    if defined(_LIGHTING_UNITY_BLINN_PHONG)
            #        define LightingUnity_GI(so, giInput, gi) LightingBlinnPhong_GI(so, giInput, gi)
            #        define LightingUnity_Deferred(so, worldViewDir, gi, diffuse, specular, normal) LightingBlinnPhong_Deferred(so, worldViewDir, gi, diffuse, specular, normal)
                so.Specular = _SpecPower / 128.0;
                so.Gloss = _Glossiness;
                // NOTE: _SpecColor is used in UnityBlinnPhongLight() used in LightingBlinnPhong().
            #    else
            #        define LightingUnity_GI(so, giInput, gi) LightingLambert_GI(so, giInput, gi)
            #        define LightingUnity_Deferred(so, worldViewDir, gi, diffuse, specular, normal) LightingLambert_Deferred(so, gi, diffuse, specular, normal)
            #    endif  // defined(_LIGHTING_UNITY_BLINN_PHONG)
                so.Alpha = color.a;
            #endif  // defined(_LIGHTING_UNITY_STANDARD)

                UnityGI gi = getGI(worldPos, atten);

                const float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
            #if !defined(LIGHTMAP_ON) && !defined(DYNAMICLIGHTMAP_ON)
                lmap = float4(0.0, 0.0, 0.0, 0.0);
            #endif  // !defined(LIGHTMAP_ON) && !defined(DYNAMICLIGHTMAP_ON)
                UnityGIInput giInput = getGIInput(gi.light, worldPos, worldNormal, worldViewDir, atten, lmap, ambient);
                LightingUnity_GI(so, giInput, gi);

                half4 emission = LightingUnity_Deferred(so, worldViewDir, gi, /* out */ diffuse, /* out */ specular, /* out */ normal);
            #if !defined(UNITY_HDR_ON)
                emission.rgb = exp2(-emission.rgb);
            #endif  // !defined(UNITY_HDR_ON)

                return emission;

            #undef LightingUnity_GI
            #undef LightingUnity_Deferred
            }

            /*!
             * Calculate lighting.
             * @param [in] color  Base color.
             * @param [in] worldPos  World coordinate.
             * @param [in] worldNormal  Normal in world space.
             * @param [in] atten  Light attenuation.
             * @param [in] lmap  Light map parameters.
             * @param [in] ambient  Ambient light.
             * @param [out] diffuse  Diffuse and occulusion. (rgb: diffuse, a: occlusion)
             * @param [out] specular  Specular and smoothness. (rgb: specular, a: smoothness)
             * @param [out] normal  Encoded normal. (rgb: normal, a: unused)
             * @return Emission color.
             */
            half4 calcLightingCustomDeferred(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap, half3 ambient, out half4 diffuse, out half4 specular, out half4 normal)
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
                const half3 diffuseColor = lightCol * pow(nDotL * 0.5 + 0.5, 2.0);  // will be mul instruction.

                // Specular reflection.
                // const half3 specularColor = pow(max(0.0, dot(normalize(worldLightDir + worldViewDir), worldNormal)), _SpecPower) * _SpecColor.rgb * lightCol;
                const half3 specularColor = pow(max(0.0, dot(reflect(-worldLightDir, worldNormal), worldViewDir)), _SpecPower) * _SpecColor.rgb * lightCol;

                // Ambient color.
            #if UNITY_SHOULD_SAMPLE_SH
                ambient = ShadeSHPerPixel(worldNormal, ambient, worldPos);
            #endif  // UNITY_SHOULD_SAMPLE_SH

                diffuse = half4((diffuseColor + ambient) * color.rgb, 1.0);
                specular = half4(specularColor, _Glossiness);
                normal = half4(worldNormal * 0.5 + 0.5, 1.0);
                return half4(0.0, 0.0, 0.0, 0.0);
            }
            ENDCG
        }

        Pass
        {
            Name "SHADOW_CASTER"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            Blend Off
            ZWrite On

            CGPROGRAM
            #pragma multi_compile_shadowcaster

            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster


            /*!
             * @brief Input of the vertex shader, vertShadowCaster().
             * @see vertShadowCaster
             */
            struct appdata_shadowcaster
            {
                //! Object space position of the vertex.
                float4 vertex : POSITION;
                //! instanceID for single pass instanced rendering.
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            /*!
             * @brief Output of the vertex shader, vertShadowCaster()
             * and input of fragment shader, fragShadowCaster().
             * @see vertShadowCaster
             * @see fragShadowCaster
             */
            struct v2f_shadowcaster
            {
                // V2F_SHADOW_CASTER;
                // `float3 vec : TEXCOORD0;` is unnecessary even if `!defined(SHADOWS_CUBE) || defined(SHADOWS_CUBE_IN_DEPTH_TEX)`
                // because calculate `vec` in fragment shader.

                //! Clip space position of the vertex.
                float4 pos : SV_POSITION;
                //! Ray origin in object/world space
                float3 rayOrigin : TEXCOORD0;
                //! Unnormalized ray direction in object/world space.
                float3 rayDirVec : TEXCOORD1;
                //! instanceID for single pass instanced rendering.
                UNITY_VERTEX_INPUT_INSTANCE_ID
                //! stereoTargetEyeIndex for single pass instanced rendering.
                UNITY_VERTEX_OUTPUT_STEREO
            };


            rayparam calcRayParam(v2f_shadowcaster fi, float maxRayLength, float maxInsideLength, bool isFace);
            float3 getCameraDirVec(float4 screenPos);


            /*!
             * @brief Vertex shader function for ShadowCaster pass.
             * @param [in] v  Input data.
             * @return Interpolation source data for fragment shader function, fragShadowCaster().
             * @see fragShadowCaster
             */
            v2f_shadowcaster vertShadowCaster(appdata_shadowcaster v)
            {
                v2f_shadowcaster o;
                UNITY_INITIALIZE_OUTPUT(v2f_shadowcaster, o);

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                //
                // TRANSFER_SHADOW_CASTER(o)
                //
                o.pos = UnityObjectToClipPos(v.vertex);
            #if !defined(SHADOWS_CUBE) || defined(SHADOWS_CUBE_IN_DEPTH_TEX)
                o.pos = UnityApplyLinearShadowBias(o.pos);
            #endif  // !defined(SHADOWS_CUBE) || defined(SHADOWS_CUBE_IN_DEPTH_TEX)

                float4 screenPos = ComputeNonStereoScreenPos(o.pos);
                COMPUTE_EYEDEPTH(screenPos.z);

            #if defined(_CALCSPACE_WORLD)
                o.rayOrigin = mul(unity_ObjectToWorld, v.vertex).xyz;
            #    if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
                o.rayDirVec = getCameraDirVec(screenPos);
            #    else
                UNITY_BRANCH
                if (UNITY_MATRIX_P[3][3] == 1.0) {
                    // For directional light.
                    o.rayDirVec = -UNITY_MATRIX_V[2].xyz;
                } else UNITY_BRANCH if (abs(unity_LightShadowBias.x) < 1.0e-5) {
                    // For depth output of camera.
                    o.rayDirVec = (o.rayOrigin - _WorldSpaceCameraPos.xyz);
                } else {
                    // For spot light.
                    o.rayDirVec = getCameraDirVec(screenPos);
                }
            #    endif
            #else
                o.rayOrigin = v.vertex.xyz;
            #    if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
                o.rayDirVec = mul((float3x3)unity_WorldToObject, getCameraDirVec(screenPos));
            #    else
                UNITY_BRANCH
                if (UNITY_MATRIX_P[3][3] == 1.0) {
                    // For directional light.
                    o.rayDirVec = mul((float3x3)unity_WorldToObject, -UNITY_MATRIX_V[2].xyz);
                } else UNITY_BRANCH if (abs(unity_LightShadowBias.x) < 1.0e-5) {
                    // For depth output of camera.
                    o.rayDirVec = o.rayOrigin - mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz;
                } else {
                    // For spot light.
                    o.rayDirVec = mul((float3x3)unity_WorldToObject, getCameraDirVec(screenPos));
                }
            #    endif
            #endif  // defined(_CALCSPACE_WORLD)

                return o;
            }


            #if defined(_CULL_FRONT) || defined(_CULL_BACK)
            /*!
             * @brief Fragment shader function for ShadowCaster pass.
             * @param [in] fi  Input data from vertex shader.
             * @param [in] facing  Facing parameter.
             * @return Depth of fragment.
             */
            fout fragShadowCaster(v2f_shadowcaster fi)
            #else
            /*!
             * @brief Fragment shader function for ShadowCaster pass.
             * @param [in] fi  Input data from vertex shader.
             * @param [in] facing  Facing parameter.
             * @return Depth of fragment.
             */
            fout fragShadowCaster(v2f_shadowcaster fi, face_t facing : FACE_SEMANTICS)
            #endif
            {
                UNITY_SETUP_INSTANCE_ID(fi);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(fi);

            #if defined(_CULL_FRONT)
                static const bool isFace = false;
            #elif defined(_CULL_BACK)
                static const bool isFace = true;
            #else
                const bool isFace = isFacing(facing);
            #endif  // defined(_CULL_FRONT)

                const rayparam rp = calcRayParam(fi, _MaxRayLength, _MaxInsideLength, isFace);
                const rmout ro = rayMarch(rp);
                if (!ro.isHit) {
                    discard;
                }

            #if defined(_CALCSPACE_WORLD)
                const float3 worldFinalPos = rp.rayOrigin + rp.rayDir * ro.rayLength;
            #else
                const float3 localFinalPos = rp.rayOrigin + rp.rayDir * ro.rayLength;
                const float3 worldFinalPos = mul(unity_ObjectToWorld, float4(localFinalPos, 1.0)).xyz;
            #endif  // defined(_CALCSPACE_WORLD)

            #if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
                //
                // TRANSFER_SHADOW_CASTER_NORMALOFFSET
                //
                const float3 vec = worldFinalPos - _LightPositionRange.xyz;

                //
                // SHADOW_CASTER_FRAGMENT
                //
                fout fo;
                fo.color = UnityEncodeCubeShadowDepth((length(vec) + unity_LightShadowBias.x) * _LightPositionRange.w);
                return fo;
            #else
                //
                // TRANSFER_SHADOW_CASTER_NORMALOFFSET
                //
                float3 worldPos = worldFinalPos;
                if (unity_LightShadowBias.z != 0.0) {
            #    if defined(USING_LIGHT_MULTI_COMPILE) && defined(USING_DIRECTIONAL_LIGHT)
                    const float3 worldLightDir = UnityWorldSpaceLightDir(worldPos);
            #    else
                    const float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
            #    endif  // defined(USING_LIGHT_MULTI_COMPILE) && defined(USING_DIRECTIONAL_LIGHT)
            #    if defined(_CALCSPACE_WORLD)
                    const float3 worldNormal = calcNormal(worldFinalPos);
            #    else
                    const float3 worldNormal = UnityObjectToWorldNormal(calcNormal(localFinalPos));
            #    endif  // defined(_CALCSPACE_WORLD)
                    const float shadowCos = dot(worldNormal, worldLightDir);
                    const float shadowSine = sqrt(1.0 - shadowCos * shadowCos);
                    const float normalBias = unity_LightShadowBias.z * shadowSine;
                    worldPos.xyz -= worldNormal * normalBias;
                }
                const float4 clipPos = UnityApplyLinearShadowBias(UnityWorldToClipPos(worldPos));

                //
                // SHADOW_CASTER_FRAGMENT
                //
                fout fo;
                fo.color = float4(0.0, 0.0, 0.0, 0.0);
            #    if defined(DEPTH_SEMANTICS)
                fo.depth = getDepth(clipPos);
            #    endif  // defined(DEPTH_SEMANTICS)
                return fo;
            #endif  // defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
            }

            /*!
             * Calculate raymarching parameters for ShadowCaster pass.
             * @param [in] fi  Input data of fragment shader function.
             * @param [in] maxRayLength  Maximum ray length.
             * @param [in] maxInsideLength  Maximum length inside an object.
             * @param [in] isFace  A flag whether the surface is facing the camera or facing away from the camera.
             * @return Ray parameters.
             */
            rayparam calcRayParam(v2f_shadowcaster fi, float maxRayLength, float maxInsideLength, bool isFace)
            {
                rayparam rp;

                rp.rayOrigin = fi.rayOrigin;
                rp.rayDir = normalize(isFace ? fi.rayDirVec : -fi.rayDirVec);
                rp.initRayLength = 0.0;
                rp.maxRayLength = maxRayLength;

                return rp;
            }

            /*!
             * @brief Get unnormalized camera direction vector from screen space position.
             * @param [in] Screen space position.
             * @return Camera direction in world space.
             */
            float3 getCameraDirVec(float4 screenPos)
            {
                float2 sp = (screenPos.xy / screenPos.w) * 2.0 - 1.0;

                // Following code is equivalent to: sp.x *= _ScreenParams.x / _ScreenParams.y;
                sp.x *= _ScreenParams.x * _ScreenParams.w - _ScreenParams.x;

                return UNITY_MATRIX_V[0].xyz * sp.x
                    + UNITY_MATRIX_V[1].xyz * sp.y
                    + -UNITY_MATRIX_V[2].xyz * abs(UNITY_MATRIX_P[1][1]);
            }
            ENDCG
        }
    }
}
