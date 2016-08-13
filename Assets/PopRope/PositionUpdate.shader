Shader "PopRope/PositionUpdate"
{
	Properties
	{
		VelocityData("VelocityData", 2D) = "white" {}
		PositionData("PositionData", 2D) = "white" {}
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
				float4 vertex : SV_POSITION;
				int RopeIndex : TEXCOORD1;
				float RopeTime : TEXCOORD2;
			};

			sampler2D PositionData;
			float4 PositionData_TexelSize;
			sampler2D VelocityData;
			float4 VelocityData_TexelSize;
			float GravityPerSecond;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

				o.RopeIndex = 0;
				o.RopeTime = v.uv.y;
				return o;
			}

			float3 GetPosition(int RopeIndex,float RopeTime)
			{
				float2 DataUv = GetDataUv( RopeIndex, RopeTime );
				float3 Position = PositionDataToPosition( tex2D( PositionData, DataUv ) );
				return Position;
			}

			float3 GetVelocity(int RopeIndex,float RopeTime)
			{
				float2 DataUv = GetDataUv( RopeIndex, RopeTime );
				float3 Position = PositionDataToPosition( tex2D( VelocityData, DataUv ) );
				return Position;
			}


			fixed4 frag (v2f i) : SV_Target
			{
				float3 Velocity = GetVelocity( i.RopeIndex, i.RopeTime );
				float3 Position = GetPosition( i.RopeIndex, i.RopeTime );

				if ( GetRopeStatic(i.RopeIndex,i.RopeTime) )
				{
					//Position = 0;
				}

				if ( !GetRopeStatic(i.RopeIndex,i.RopeTime) )
				{
					//	move
					Position += Velocity;

					//	collision
					if ( Position.y < 0 )
						Position.y = 0;
				}

				float3 PosData = PositionToPositionData( Position );
				return float4(PosData,1);
			}
			ENDCG
		}
	}
}
