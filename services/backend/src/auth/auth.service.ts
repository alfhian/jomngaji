import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

import { UsersService } from '../users/users.service';
import { SignInDto } from './dto/sign-in.dto';
import { SignUpDto } from './dto/sign-up.dto';
import { TokenResponseDto } from './dto/token-response.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  async signUp(payload: SignUpDto): Promise<TokenResponseDto> {
    const user = await this.usersService.createUser(payload);
    return this.signToken(user.id);
  }

  async signIn(payload: SignInDto): Promise<TokenResponseDto> {
    const user = await this.usersService.validateUser(payload.email, payload.password);
    return this.signToken(user.id);
  }

  private async signToken(userId: string): Promise<TokenResponseDto> {
    const accessToken = await this.jwtService.signAsync({ sub: userId });
    return { accessToken };
  }
}
