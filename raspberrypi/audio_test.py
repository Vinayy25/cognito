
import pygame

pygame.init()

sound = pygame.mixer.Sound("testaudio.ogg")
sound.play()

while pygame.mixer.get_busy():
    pygame.time.wait(100)
