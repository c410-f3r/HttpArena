FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build

# Clone zerg from source (NuGet package missing core.dll — ConnectionBase lives there)
RUN apt-get update && apt-get install -y --no-install-recommends git && \
    git clone --depth 1 https://github.com/MDA2AV/zerg.git /src/zerg-repo

WORKDIR /app
COPY . .
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/runtime:10.0-preview
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 8080
ENTRYPOINT ["dotnet", "zerg-httparena.dll"]
