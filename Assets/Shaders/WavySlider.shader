Shader "Custom/WavySlider"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
		_TotalNodes("Total Number of Nodes", Range (1,50)) = 1  /*wave length*/
		_Period("Period (offset pixels)", Range (1,50)) = 1
		_Frequency("Frequency (offset pixels width)", Range (1,50)) = 10 
		_Amplitude("Amplitude (offset pixels height)", Range (1,50)) = 10 /* wave height */
	}

	/* no frequency - need to use number of nodes as wave length
  return sin((x / wavelength * (Math.PI * 2)) + frames / frequency) * amplitude;

  original formula:
       float offsetInput = (_Time.y + frac(worldPos.x)) * _WobblesPerSecond * TWO_PI + worldPos.x / _WobblePeriod;

	*/

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest[unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color : COLOR;
				half2 texcoord  : TEXCOORD0;
			};

			fixed4 _Color;
			fixed4 _TextureSampleAdd;

			int _TotalNodes;
			float _Period;
			float _Amplitude;
			float _Frequency;

			#define PI 3.14159
			#define TWO_PI 6.28318

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				float4 worldPos = IN.vertex;
				float3 unit=UnityObjectToClipPos(float3(1,1,0))-UnityObjectToClipPos(float3(0,0,0));
				/*magic
			float impactAxis = l_ImpactOrigin + dot((v.vertex - l_ImpactOrigin), l_direction);
			v.vertex.xyz += v.normal * sin(impactAxis * _Frequency + _ControlTime * _WaveSpeed) * _Amplitude * (1 / dist);

			o.pos.x+=sin((wpos.y*_WaveFrequency)-(_Time.a*_WaveSpeed))*(_WaveForce*unit.x*multiplier);
				*/

				/* worldPos.y += sin((worldPos.x/_TotalNodes) * TWO_PI + worldPos.x / _Period) * _Amplitude;
				worldPos.x += sin((worldPos.x * _Frequency /_TotalNodes) * TWO_PI + worldPos.x / _Period) * _Frequency; */

				worldPos.y += sin((worldPos.x/_TotalNodes) * TWO_PI + worldPos.x / _Period) * _Amplitude;
				
				worldPos.x += sin((worldPos.y * _TotalNodes) * _Amplitude*unit.x); 
				OUT.vertex = UnityObjectToClipPos(worldPos);
				OUT.texcoord = IN.texcoord;

		#ifdef UNITY_HALF_TEXEL_OFFSET
				OUT.vertex.xy += (_ScreenParams.zw - 1.0)*float2(-1,1);
		#endif
				OUT.color = IN.color * _Color;
				return OUT;
			}

			sampler2D _MainTex;
			fixed4 frag(v2f IN) : SV_Target
			{
				return (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
			}
			ENDCG
		}
	}
}