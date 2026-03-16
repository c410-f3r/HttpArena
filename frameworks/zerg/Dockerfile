FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build

# Install clang for NativeAOT linking
RUN apt-get update && apt-get install -y --no-install-recommends clang zlib1g-dev && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Clone zerg source (NuGet package has broken 'core' dependency — resolves to wrong package)
RUN git clone --depth 1 https://github.com/MDA2AV/zerg.git /src/zerg-repo

WORKDIR /app
COPY . .

# Replace NuGet PackageReference with ProjectReference to zerg source
RUN sed -i 's|<PackageReference Include="zerg" Version="[^"]*" />|<ProjectReference Include="/src/zerg-repo/zerg/zerg.csproj" />|' zerg-httparena.csproj

RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/runtime:10.0-preview
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 8080
ENTRYPOINT ["dotnet", "zerg-httparena.dll"]
