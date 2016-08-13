#define POSITION_SCALE	10
#define POSITION_MIN	float3(-POSITION_SCALE,-POSITION_SCALE,-POSITION_SCALE)
#define POSITION_MAX	float3(POSITION_SCALE,POSITION_SCALE,POSITION_SCALE)

float Range(float Min,float Max,float Value)
{
	return (Value-Min) / (Max-Min);
}

float3 Range3(float3 Min,float3 Max,float3 Value)
{
	return float3( Range(Min.x,Max.x,Value.x), Range(Min.y,Max.y,Value.y), Range(Min.z,Max.z,Value.z) );
}

float3 PositionDataToPosition(float3 PosData)
{
	PosData = lerp( POSITION_MIN, POSITION_MAX, PosData );
	return PosData;
}

float3 PositionToPositionData(float3 Pos)
{
	return clamp( 0, 1, Range3( POSITION_MIN, POSITION_MAX, Pos ) );
}

float2 GetDataUv(int RopeIndex,float RopeTime)
{
	return float2( (float)RopeIndex, RopeTime );
}

bool GetRopeStatic(int RopeIndex,float RopeTime)
{
	return (RopeTime > 0.8f);
}
