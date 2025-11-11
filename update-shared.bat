@echo off
echo ====================================
echo Updating shared package in all services
echo ====================================

echo.
echo [1/4] Updating api-gateway...
cd api-gateway
call yarn upgrade @wo0zz1/url-shortener-shared --latest
cd ..

echo.
echo [2/4] Updating user-service...
cd user-service
call yarn upgrade @wo0zz1/url-shortener-shared --latest
cd ..

echo.
echo [3/4] Updating auth-service...
cd auth-service
call yarn upgrade @wo0zz1/url-shortener-shared --latest
cd ..

echo.
echo [4/4] Updating link-service...
cd link-service
call yarn upgrade @wo0zz1/url-shortener-shared --latest
cd ..