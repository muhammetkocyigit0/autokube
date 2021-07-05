FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443


FROM alpine:latest as build-node
RUN apk --update add nodejs npm
COPY . .
WORKDIR "./%ProjectName%/ClientApp"
RUN ls -l
RUN npm install
RUN npm run build

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src
COPY . .
WORKDIR "./%ProjectName%"
RUN ls -l
RUN dotnet build "%ProjectName%.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "%ProjectName%.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app/run
COPY --from=publish /app/publish .
COPY --from=build-node "/%ProjectName%/ClientApp/build" ./ClientApp/build
RUN cp /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
ENTRYPOINT ["dotnet", "%ProjectName%.dll"]