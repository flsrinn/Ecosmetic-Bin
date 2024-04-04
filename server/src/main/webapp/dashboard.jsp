<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>대시보드</title>
    <style>
        body {
            background-color: #F5F5F5;
            font-family: Arial, sans-serif;
        }


        #user-info {
            margin-top: 50px;
            font-size: 32px;
            color: #333;
        }

        #user-level {
            font-size: 18px;
            color: #555;
        }
		
		.show-mileage, .mileage-calendar, .mileage-chart {
            background-color: white;
            border-radius: 30px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 500px;
            display : flex;       
            align-items : center;
		}
		
		.show-mileage {
			font-size: 20px;
		}
		
		.mileage-calendar {
			text-align: center;
			justify-content : center;
			font-size: 20px;
			word-spacing:5px;
		}
		
		.mileage-calendar table {
        	width: 100%;
        	table-layout: fixed;
    	}

    	.mileage-calendar table td {
        	width: 14.28%;
        	vertical-align: top;
    	}

        @media only screen and (max-width: 600px) {
            input[type="text"],
            input[type="button"] {
                width: 100%;
                max-width: 300px;
            }
        }
    </style>
</head>
<body>
<%
    String loggedInUserId = (String) session.getAttribute("loggedInUser");

    // 데이터베이스 연결 정보
    String url = "jdbc:mysql://localhost:3306/ecosmeticbin";
    String username = "root";
    String password = "1234";

    // 사용자 정보를 담을 변수
    String userId = "";
    String level = "";
    String levelname = "";
    int totalmileage =0;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // 데이터베이스 연결
        conn = DriverManager.getConnection(url, username, password);

        String sql = "SELECT u.id, u.level, u.totalmileage, l.levelname " +
                "FROM user u " +
                "JOIN history h ON u.id = h.id " +
                "JOIN level l ON u.level = l.level " +
                "WHERE u.id = ?";
        
        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, loggedInUserId);

        // 쿼리 실행
        rs = pstmt.executeQuery();

        // 결과 확인
        if (rs.next()) {
            // 사용자 정보 추출
            userId = rs.getString("id");
            level = rs.getString("level");
            levelname = rs.getString("levelname");
            totalmileage = rs.getInt("totalmileage");
        }
    } catch (SQLException e) {
        out.println("오류 발생: " + e.getMessage());
    } finally {
        // 연결 및 리소스 해제
        try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>

<div id="user-info" style="display: flex;">
    <strong><%= userId %> 님, 안녕하세요!<br></strong>
    <%-- Lv <%= level %> <%= levelname %>--%>
</div><br>

<div class="show-mileage">
	<img src="mileage-coin.png" alt="User Image" style="width: 100px; height: 100px; border-radius: 50%; margin-right: 20px;" />
		총 마일리지
		<strong><%= totalmileage %> M </strong>
</div> <br>

<div class="mileage-calendar">
	<button onclick="prevMonth()">이전</button>
    <button onclick="nextMonth()">다음</button>
	<script>
    var currentDate = new Date(); // 현재 날짜를 가져옵니다.
    var currentYear = currentDate.getFullYear(); // 현재 연도를 가져옵니다.
    var currentMonth = currentDate.getMonth() + 1; // 현재 월을 가져옵니다. (월은 0부터 시작하므로 1을 더합니다.)

    function getDaysInMonth(year, month) {
        return new Date(year, month, 0).getDate(); // 해당 연도와 월의 일 수를 반환합니다.
    }

    function generateCalendar(year, month) {
        var daysInMonth = getDaysInMonth(year, month); // 해당 연도와 월의 일 수를 가져옵니다.
        var calendarHTML = '<table>'; // 달력을 만들기 위한 HTML 문자열을 초기화합니다.

        calendarHTML += '<tr><th colspan="7">' + month + '월 ' + year + '년</th></tr>'; // 달력의 제목 행을 추가합니다.
        calendarHTML += '<tr><th>일</th><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th>토</th></tr>'; // 요일 표시 행을 추가합니다.

        var date = new Date(year, month - 1, 1); // 현재 달의 첫째 날의 Date 객체를 생성합니다.

        calendarHTML += '<tr>';
        for (var i = 0; i < date.getDay(); i++) {
            calendarHTML += '<td></td>'; // 이전 달의 날짜를 비워둡니다.
        }

        for (var day = 1; day <= daysInMonth; day++) {
            var dayStr = day.toString(); // 일자를 문자열로 변환합니다.
            var backgroundColor = 'lightgray'; // 기본 배경색을 설정합니다.

            // 특정 날짜의 재활용 횟수를 확인하여 배경색을 설정합니다.
            // 만약 해당 날짜의 재활용 횟수가 1 이상이면 초록색으로 표시합니다.
            if (checkRecyclingCount(year, month, day)) {
                backgroundColor = 'green';
            }

            calendarHTML += '<td style="text-align: center; position: relative;">' + dayStr + '<br>' + '<div style="width: 20px; height: 20px; background-color: ' + backgroundColor + '; display: inline-block; margin-top: 2px;"></div>' + '</td>'; // 날짜를 표시하고 배경색을 설정합니다.
            if (date.getDay() === 6) { // 토요일일 경우 다음 행으로 이동합니다.
                calendarHTML += '</tr><tr>';
            }
            date.setDate(date.getDate() + 1); // 다음 날짜로 이동합니다.
        }

        while (date.getDay() > 0 && date.getDay() < 7) {
            calendarHTML += '<td></td>'; // 다음 달의 날짜를 비워둡니다.
            date.setDate(date.getDate() + 1);
        }

        calendarHTML += '</tr></table>'; // 달력을 마무리합니다.
        return calendarHTML; // 생성된 달력 HTML을 반환합니다.
    }

    // 데이터베이스에서 특정 날짜의 재활용 횟수를 확인하는 함수입니다.
    function checkRecyclingCount(year, month, day) {
        // 여기에 실제 데이터베이스 쿼리를 사용하여 특정 날짜의 재활용 횟수를 확인하는 코드를 구현해야 합니다.
        // 해당 날짜의 재활용 횟수가 1 이상이면 true를 반환하고, 그렇지 않으면 false를 반환합니다.
        // 이 예제에서는 간단히 날짜가 홀수인 경우 true를 반환하고 짝수인 경우 false를 반환합니다.
        return day % 2 !== 0; // 예제 로직입니다. 실제 데이터베이스 쿼리로 대체되어야 합니다.
    }

    document.querySelector('.mileage-calendar').innerHTML = generateCalendar(currentYear, currentMonth); // 초기 달력을 생성합니다.

    function prevMonth() {
        currentMonth--; // 이전 달로 이동합니다.
        if (currentMonth < 1) { // 만약 현재 월이 1월인 경우 이전 해의 12월로 이동합니다.
            currentMonth = 12;
            currentYear--;
        }
        refreshCalendar(); // 달력을 새로고칩니다.
    }

    function nextMonth() {
        currentMonth++; // 다음 달로 이동합니다.
        if (currentMonth > 12) { // 만약 현재 월이 12월인 경우 다음 해의 1월로 이동합니다.
            currentMonth = 1;
            currentYear++;
        }
        refreshCalendar(); // 달력을 새로고칩니다.
    }
    
    function refreshCalendar() {
        document.querySelector('.mileage-calendar').innerHTML = generateCalendar(currentYear, currentMonth); // 달력을 새로 고칩니다.
    }
</script>
	<br>
	<div style="text-align: center; margin-top: 20px;">
        <img src="range.png" width="50px" height="10px">
    </div>
    </div>
<br>
<div class="mileage-chart">
		차트들어갈곳
</div>
<br>
</body>
</html>