package com.kuuuurt.template

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform