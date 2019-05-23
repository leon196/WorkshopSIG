using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(Geometry))]
public class GeometryEditor : Editor
{
	public override void OnInspectorGUI ()
	{
		serializedObject.Update();
		DrawDefaultInspector();
		Geometry script = (Geometry)target;
		
		if(GUILayout.Button("Generate"))
		{
			script.Start();
		}
	}
}
