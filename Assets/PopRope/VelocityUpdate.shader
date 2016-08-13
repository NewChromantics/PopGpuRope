Shader "PopRope/VelocityUpdate"
{
	Properties
	{
		VelocityData("VelocityData", 2D) = "red" {}
		PositionData("PositionData", 2D) = "white" {}

		AirFriction("AirFriction", Range(0,1) ) = 0.2
		GravityPerSecond("GravityPerSecond", Range(-5,5) ) = 0
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
				int RopeIndex : TEXCOORD1;
				float RopeTime : TEXCOORD2;
			};

			sampler2D PositionData;
			float4 PositionData_TexelSize;
			sampler2D VelocityData;
			float4 VelocityData_TexelSize;
			float GravityPerSecond;
			float AirFriction;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				o.RopeIndex = 0;

				//	gr: always 0
				o.RopeTime = v.uv.y;
				return o;
			}

			float3 GetPosition(float RopeTime)
			{
				float2 DataUv = GetDataUv( 0, RopeTime );
				float3 Position = PositionDataToPosition( tex2D( PositionData, DataUv ) );
				return Position;
			}

			float4 frag (v2f i) : SV_Target
			{
				
				//float3 Position = float3(0,GravityPerSecond,0);
				//float3 PosData = PositionToPositionData( Position );
				//return float4( PosData, 1 );

				float3 Velocity = PositionDataToPosition( tex2D( VelocityData, GetDataUv(i.RopeIndex,i.RopeTime) ) );
				float TimeDelta = 1.0/60.0;
				//	air damping
				Velocity *= 1 - AirFriction;

				//	add gravity
				Velocity.y += GravityPerSecond * TimeDelta;


				/*
				//	spring to neighbour
				if ( !GetRopeStatic(i.RopeIndex,i.RopeTime) )
				{
					float3 PrevPos = GetPosition( i.uv.x - 0.001f );
					float3 Pos = GetPosition( i.uv.x );
					float3 NextPos = GetPosition( i.uv.x + 0.001f );

					float RopeChunkLength = 0.2f;

					//	work out where we WANT to be
					float3 DeltaToPrev = normalize(PrevPos - Pos);
					float3 TargetDeltaToPrev = DeltaToPrev * RopeChunkLength;
					//	move this much to be at target
					Velocity += TargetDeltaToPrev - DeltaToPrev;

				}
				*/

				if ( GetRopeStatic(i.RopeIndex,i.RopeTime) )
				{
					Velocity.y = i.RopeTime * 2;
				}

				float3 VelocityData = PositionToPositionData( Velocity );
				return float4(VelocityData,1);

			}
			ENDCG
		}
	}
}
