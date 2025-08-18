<?php

if(!isset($_SESSION['login'])){ //if login in session is not set
    header("Location: http://www.example.com/login.php");
}
?>