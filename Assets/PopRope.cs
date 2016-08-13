using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PopRope : MonoBehaviour {

	public RenderTexture PositionData;
	public Material PositionInit;
	public Material PositionUpdate;

	public RenderTexture VelocityData;
	public Material VelocityInit;
	public Material VelocityUpdate;

	void Start () {

		Graphics.Blit (null, PositionData, PositionInit);
		Graphics.Blit (null, VelocityData, VelocityInit);
	
	}


	public RenderTexture PositionTemp;
	public RenderTexture VelocityTemp;

	void Update () {

		if ( PositionTemp == null )
			PositionTemp = RenderTexture.GetTemporary (PositionData.width, PositionData.height, 0);
		if ( VelocityTemp == null )
			VelocityTemp = RenderTexture.GetTemporary (PositionData.width, PositionData.height, 0);

		//	update velocity
		Graphics.Blit (VelocityData, VelocityTemp);
		if (VelocityUpdate != null) {
			VelocityUpdate.SetTexture ("PositionData", PositionData);
			VelocityUpdate.SetTexture ("VelocityData", VelocityTemp);
			Graphics.Blit (null, VelocityData, VelocityUpdate);
		}

		//	update pos
		Graphics.Blit (PositionData, PositionTemp);
		if (PositionUpdate != null) {
			PositionUpdate.SetTexture ("PositionData", PositionTemp);
			PositionUpdate.SetTexture ("VelocityData", VelocityData);
			Graphics.Blit (null, PositionData, PositionUpdate);
		}


		//RenderTexture.ReleaseTemporary (Temp);
	}
}
