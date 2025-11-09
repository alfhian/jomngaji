import { Body, Controller, Post } from '@nestjs/common';

import { AuthService } from './auth.service';
import { SignInDto } from './dto/sign-in.dto';
import { SignUpDto } from './dto/sign-up.dto';
import { TokenResponseDto } from './dto/token-response.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('signup')
  async signUp(@Body() payload: SignUpDto): Promise<TokenResponseDto> {
    return this.authService.signUp(payload);
  }

  @Post('signin')
  async signIn(@Body() payload: SignInDto): Promise<TokenResponseDto> {
    return this.authService.signIn(payload);
  }
}
