
local timeToBlend = 10000
local currentWeather = 0

setRainLevel(0)

function renderWeatherBlending()
    if not weatherToOverBlend then
        return
    end
    if getTickCount() > endTime then
        removeEventHandler("onClientPreRender", root, renderWeatherBlending)
        currentWeather = weatherToOverBlend
        weatherToOverBlend = nil
        currentWeatherData = nil
        hasWeatherBeenSet = nil
        outputChatBox("finished WeatherBlending")
        return
    end

    local data = getWeatherData(weatherToOverBlend, getTime())

    local now = getTickCount()
	local elapsedTime = now - startTime
	local duration = endTime - startTime
    local progress = elapsedTime / duration


    local farClipDistance, nearClipDistance, fogDistance = interpolateBetween(currentWeatherData.farClipDistance, currentWeatherData.nearClipDistance, currentWeatherData.fogDistance, data.farClipDistance, data.nearClipDistance, data.fogDistance, progress, "Linear")
    local skyGradientR1, skyGradientG1, skyGradientB1 = interpolateBetween(currentWeatherData.skyGradientR1, currentWeatherData.skyGradientG1, currentWeatherData.skyGradientB1, data.skyGradient.r1, data.skyGradient.g1, data.skyGradient.b1, progress, "Linear")
    local skyGradientR2, skyGradientG2, skyGradientB2 = interpolateBetween(currentWeatherData.skyGradientR2, currentWeatherData.skyGradientG2, currentWeatherData.skyGradientB2, data.skyGradient.r2, data.skyGradient.g2, data.skyGradient.b2, progress, "Linear")
    local moonSize, sunSize = interpolateBetween(currentWeatherData.moonSize, currentWeatherData.sunSize, 0, data.moonSize, data.sunSize, 0, progress, "Linear")
    local waterColorR, waterColorG, waterColorB = interpolateBetween(currentWeatherData.waterColorR, currentWeatherData.waterColorG, currentWeatherData.waterColorB, data.waterColor.r, data.waterColor.g, data.waterColor.b, progress, "Linear")
    local sunColorR, sunColorG, sunColorB = interpolateBetween(currentWeatherData.sunColorR, currentWeatherData.sunColorG, currentWeatherData.sunColorB, data.sunColor.r, data.sunColor.g, data.sunColor.b, progress, "Linear")
    local windVelocityX, windVelocityY, windVelocityZ = interpolateBetween(currentWeatherData.windVelocityX, currentWeatherData.windVelocityY, currentWeatherData.windVelocityZ, data.windVelocity.x, data.windVelocity.y, data.windVelocity.z, progress, "Linear")

    setFarClipDistance(farClipDistance)
    setNearClipDistance(nearClipDistance)
    setFogDistance(fogDistance)
    setSkyGradient(skyGradientR1, skyGradientG1, skyGradientB1, skyGradientR2, skyGradientG2, skyGradientB2)
    setMoonSize(moonSize)
    setSunSize(sunSize)
    setWaterColor(waterColorR, waterColorG, waterColorB)
    setSunColor(sunColorR, sunColorG, sunColorB)
    setWindVelocity(windVelocityX, windVelocityY, windVelocityZ)

    if hasWeatherBeenSet ~= true then
        if progress > 0.5 then 
            setWeather(weatherToOverBlend)
            hasWeatherBeenSet = true
        end
    end
end

function setNewWeatherBlending(id)
    weatherToOverBlend = id
    startTime = getTickCount()
    endTime = getTickCount() + timeToBlend
    hasWeatherBeenSet = false

    local skyGradientR1, skyGradientG1, skyGradientB1, skyGradientR2, skyGradientG2, skyGradientB2 = getSkyGradient()
    local waterColorR, waterColorG, waterColorB = getWaterColor()
    local sunColorR, sunColorG, sunColorB = getSunColor()
    local windVelocityX, windVelocityY, windVelocityZ = getWindVelocity()

    currentWeatherData = {
        farClipDistance = getFarClipDistance(), 
        nearClipDistance = getNearClipDistance(), 
        fogDistance = getFogDistance(), 
        skyGradientR1 = skyGradientR1, skyGradientG1 = skyGradientG1, skyGradientB1 = skyGradientB1, skyGradientR2 = skyGradientR2, skyGradientG2 = skyGradientG2, skyGradientB2 = skyGradientB2,
        moonSize = getMoonSize(), 
        sunSize = getSunSize(),
        waterColorR = waterColorR, waterColorG = waterColorG, waterColorB = waterColorB,
        sunColorR = sunColorR, sunColorG = sunColorG, sunColorB = sunColorB,
        windVelocityX = windVelocityX, windVelocityY = windVelocityY, windVelocityZ = windVelocityZ
    }

    addEventHandler("onClientPreRender", root, renderWeatherBlending)
    outputChatBox("started WeatherBlending")
end

function setNewWeather(id)
    weatherToOverBlend = nil
    currentWeather = id
end

function getWeatherData(weather, time)
    return weatherData[weather][time]
end
