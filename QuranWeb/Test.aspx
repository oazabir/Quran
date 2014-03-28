<%@ Page Language="C#" AutoEventWireup="true" ValidateRequest="false" %>
<%
var ayah = Convert.ToInt32(Request["ayah"] ?? "1");
var surah = Convert.ToInt32(Request["surah"] ?? "1");
Response.Redirect("http://alquranu.com/" + surah + "/" + ayah + "/");
%>
