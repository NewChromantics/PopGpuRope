Shader "PopRope/PopRopeRender"
{
	Properties
	{
		PositionData("PositionData", 2D) = "white" {}
		VelocityData("VelocityData", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Cull off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

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
				float3 LocalPos : TEXCOORD3;

				int RopeIndex : TEXCOORD1;
				float RopeTime : TEXCOORD2;
			};

			sampler2D PositionData;
			sampler2D VelocityData;
			float4 PositionData_TexelSize;
			float4 VelocityData_TexelSize;

				

			v2f vert (appdata v)
			{
				v2f o;

				//	take rotation/scale (gr: remove translation)
				//float3 LocalPos = mul( _Object2World, float4(v.vertex) ).xyz;
				float3 LocalPos = v.vertex.xyz;
				//LocalPos.y = 0;
				//LocalPos.x = LocalPos.x < 0 ? -1 : 1;
				//LocalPos.z = LocalPos.z < 0 ? -1 : 1;

				o.uv = v.uv;
				o.RopeIndex = 0;
				o.RopeTime = v.uv.x;
				float2 DataUv = GetDataUv( o.RopeIndex, o.RopeTime );

				//LocalPos = 0;
				LocalPos += PositionDataToPosition( tex2Dlod( PositionData, float4( DataUv, 0, 0 ) ) );

				o.vertex = mul(UNITY_MATRIX_VP, float4(LocalPos,1) );

				o.LocalPos = LocalPos;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//return float4( i.uv, 0, 1 );
				if ( GetRopeStatic(i.RopeIndex,i.RopeTime) )
					return float4( 1, 0, 0, 1 );
				else
					return float4( 0, 1, 0, 1 );

					/*
				return tex2D( VelocityData, i.uv );
				return float4( i.DataUv, 0, 1 );
				float3 VelocityData3 = tex2D( VelocityData, i.DataUv ).xyz;


				//return float4( i.LocalPos.x, i.LocalPos.y, i.LocalPos.z, 1 );
				return float4( VelocityData3, 1 );
				*/
			}
			ENDCG
		}
	}
}
