B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region

#Macro: Title, Export B4XPages, ide://run?File=%B4X%\Zipper.jar&Args=%PROJECT_NAME%.zip

Sub Class_Globals
	Private Root As B4XView
	Private xui As XUI
	Dim swiperefresh As View
End Sub

Public Sub Initialize
'	B4XPages.GetManager.LogEvents = True
End Sub
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1

	'Load the B4X layout only if you actually need MainPage
	Root.LoadLayout("MainPage")

	'Inflate the XML layout
	Dim inflatedView As View = InflateLayout("main", Root)

	If inflatedView.IsInitialized = False Then
		Log("ERROR: main.xml could not be inflated")
		Return
	End If

	Root.AddView(inflatedView, 0, 0, 100%x, 100%y)

	'Get Android resource ID
	Dim swipeId As Int = GetViewResourceId("swipetorefresh")
	Log("swipetorefresh ID = " & swipeId)

	If swipeId = 0 Then
		Log("ERROR: swipetorefresh resource ID = 0")
		Return
	End If

	'Find SwipeRefreshLayout inside the inflated XML
	Dim rootJO As JavaObject = inflatedView
	Dim swipeJO As JavaObject = rootJO.RunMethod("findViewById", Array(swipeId))

	If swipeJO.IsInitialized = False Then
		Log("ERROR: findViewById returned null")
		Return
	End If

	Log("SwipeRefreshLayout FOUND")

	swiperefresh = swipeJO

	'Create listener
	Dim event As Object = swipeJO.CreateEventFromUI("androidx.swiperefreshlayout.widget.SwipeRefreshLayout.OnRefreshListener","onRefreshing",Null)

	swipeJO.RunMethod("setOnRefreshListener", Array(event))
End Sub
'

Private Sub onRefreshing_Event(MethodName As String, Args() As Object)
	Log($"Refreshing:${MethodName}"$)
	Update
   
End Sub
Private Sub Update
	' When refresh is done:
	swiperefresh.As(JavaObject).RunMethod("setRefreshing", Array(False))
	'xui.MsgboxAsync("Refresh done","Swipe to refresh")
	
End Sub
Sub InflateLayout(LayoutName As String, Parent As Panel) As View
	Dim context As JavaObject
	context.InitializeContext

	' Get Resources and LayoutInflater
	Dim resources As JavaObject
	resources = context.RunMethod("getResources", Null)
    
	Dim inflater As JavaObject
	inflater = context.RunMethod("getSystemService", Array("layout_inflater"))

	' Get the resource ID (e.g., R.layout.my_layout)
	Dim resName As String = LayoutName.Replace(".xml", "") ' Remove .xml extension
	Dim resID As Int = resources.RunMethod("getIdentifier", Array(resName, "layout",Application.PackageName))
    
	If resID = 0 Then
		Log("Error: Layout file not found in resources - " & LayoutName)
		Return Null
	End If

	' Inflate using the resource ID
	Dim view As JavaObject
	view = inflater.RunMethod("inflate", Array(resID, Parent, False))

	Return view
End Sub

Sub GetViewResourceId(ViewName As String) As Int
	Dim context As JavaObject
	context.InitializeContext
	Dim resources As JavaObject = context.RunMethod("getResources", Null)
	Dim pkg As String = context.RunMethod("getPackageName", Null)
	Return resources.RunMethod("getIdentifier", Array(ViewName, "id", pkg))
End Sub
Sub getDrawable(drawableName As String) As JavaObject
	' Get the animated vector drawable resource ID
	Dim resId As Int = GetResourceId(drawableName, "drawable")
    
	' Load the drawable
	Dim resources As JavaObject
	resources.InitializeContext.RunMethodJO("getResources", Null)
	Dim drawable As JavaObject = resources.RunMethod("getDrawable", Array(resId))
	Return drawable
End Sub

Sub GetResourceId(name As String, resType As String) As Int
	Dim jo As JavaObject
	jo.InitializeContext
	Return jo.RunMethodJO("getResources", Null).RunMethod("getIdentifier", _
        Array(name, resType, Application.PackageName))
End Sub
