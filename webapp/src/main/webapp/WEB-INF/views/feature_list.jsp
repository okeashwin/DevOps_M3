<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
</head>
<body>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <table border="1">
        <tr>
            <th>Feature Name</th>
            <th>Flag</th>
        </tr>
        <c:forEach items="${features}" var="f">
            <tr>
                <td><c:out value="${f.key}"/></td>
                <td><c:out value="${f.value}"/></td>
            </tr>
        </c:forEach>
    </table>
</body>
</html>