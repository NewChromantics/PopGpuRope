Shader "Unlit/InitPos"
{
	Properties
	{
		PositionDataLast ("PositionDataLast", 2D) = "white" {}
		GravityPerSecond("GravityPerSecond", Range(0,4) ) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "../PopRope/PopRope.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D PositionDataLast;
			float4 PositionDataLast_TexelSize;
			float GravityPerSecond;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//	copy old position
				float3 OldPos = PositionDataToPosition( tex2D( PositionDataLast, i.uv ) );

				//	gravity
				float3 GravityVelocity = float3( 0, -GravityPerSecond, 0 );
				//Velocity *= 1/60;
				//OldPos.xyz += Velocity;

				float3 SpringVelocity = (float3(0,0,0)-OldPos) * 0.2f;
				SpringVelocity = normalize(SpringVelocity);
				SpringVelocity *= 0.333f;

				//Velocity = lerp( OldPos, float3(0,0,0), 0.1f );
				//float3 Velocity = 
				//Velocity = normalize(Velocity);
				//Velocity *= 0.333f;

				OldPos += GravityVelocity;
				OldPos += SpringVelocity;



				//if ( OldPos.y < 0 )
				//	OldPos.y = 0;
			
				float3 PosData = PositionToPositionData( OldPos );
				return float4(PosData,1);
			}
			ENDCG
		}
	}
}
