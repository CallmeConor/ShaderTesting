using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PaintingWithShader : MonoBehaviour
{
	public Color ClearColour;
	public Material PaintShader;
	public RenderTexture PaintTarget;
	private RenderTexture TempRenderTarget;
	private Material ThisMaterial;

	enum BrushDir
	{
		Down,
		Right
	}

	void Start()
	{
		Init();
	}
	void Init()
	{
		if (ThisMaterial == null)
			ThisMaterial = this.GetComponent<Renderer>().material;

		//  already setup
		if (PaintTarget != null)
		{
			if (ThisMaterial.mainTexture == PaintTarget)
			{
				return;
			}
		}

		//  copy texture
		if (ThisMaterial.mainTexture != null)
		{
			if (PaintTarget == null)
				PaintTarget = new RenderTexture(ThisMaterial.mainTexture.width, ThisMaterial.mainTexture.height, 0);
			Graphics.Blit(ThisMaterial.mainTexture, PaintTarget);
			ThisMaterial.mainTexture = PaintTarget;
		}
		else
		{
			if (PaintTarget == null)
				PaintTarget = new RenderTexture(1024, 1024, 0);

			//  clear if no existing texture
			Texture2D ClearTexture = new Texture2D(1, 1);
			ClearTexture.SetPixel(0, 0, ClearColour);
			Graphics.Blit(ClearTexture, PaintTarget);
			ThisMaterial.mainTexture = PaintTarget;
		}
	}

	float xHelper = 0f;
	bool helpingX = false;

	// Update is called once per frame
	void Update()
	{
		RaycastHit hitInfo = new RaycastHit();
		Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

		if (Input.GetMouseButton(0))
		{
			// Enable the brush
			if(PaintShader.GetInt("PaintBrushEnabled") == 0)
			{
				PaintShader.SetInt("PaintBrushEnabled", 1);
			}

			if (Physics.Raycast(ray, out hitInfo))
			{
				if (!helpingX)
				{
					Debug.Log("SetX");
					xHelper = hitInfo.textureCoord.x;
					helpingX = true;
				}
				PaintShader.SetVector("PaintUv", new Vector2(xHelper, hitInfo.textureCoord.y));
				hitInfo.collider.SendMessage("HandleClick", hitInfo, SendMessageOptions.DontRequireReceiver);
			}
		}
		if(Input.GetMouseButtonUp(0) && helpingX)
		{
			PaintShader.SetInt("PaintBrushEnabled", 0);
			helpingX = false;
		}
	}

	void HandleClick(RaycastHit Hit)
	{
		Vector2 LocalHit2 = Hit.textureCoord;
		PaintAt(LocalHit2);
	}


	void PaintAt(Vector2 Uv)
	{
		Init();
		if (TempRenderTarget == null)
		{
			TempRenderTarget = new RenderTexture(PaintTarget.width, PaintTarget.height, 0);
		}
		Graphics.Blit(PaintTarget, TempRenderTarget);
		Graphics.Blit(TempRenderTarget, PaintTarget, PaintShader);
	}
}
