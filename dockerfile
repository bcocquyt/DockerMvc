FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /app
COPY /app /app
ENTRYPOINT ["dotnet" , "docker_mvc.dll"]