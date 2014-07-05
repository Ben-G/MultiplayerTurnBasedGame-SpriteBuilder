//
//  PreMatchScene.m
//  MultiplayerTurnBasedGame
//
//  Created by Benjamin Encz on 06/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "PreMatchScene.h"
#import <mgwuSDK/MGWU.h>
#import "UserInfo.h"
#import "GameDataUtils.h"
#import "Constants.h"

NSString * const START_ROUND_STRING = @"It’s your turn to start this round!";
NSString * const FINISH_ROUND_STRING = @"It's your turn to finish this round!";

NSString * const GAME_OVER_WIN = @"Game ended. You won!";
NSString * const GAME_OVER_LOSE = @"Game ended. You lost!";
NSString * const GAME_OVER_DRAW = @"Game ended with a draw";

@implementation PreMatchScene {
  CCLabelTTF *_playerNameLabel;
  CCLabelTTF *_opponentNameLabel;
  CCLabelTTF *_currentRound;
  
  // labels
  CCLabelTTF *_playerRound1;
  CCLabelTTF *_playerRound2;
  CCLabelTTF *_playerRound3;
  
  CCLabelTTF *_opponentRound1;
  CCLabelTTF *_opponentRound2;
  CCLabelTTF *_opponentRound3;
  
  CCLabelTTF *_actionInfoLabel;
}

- (void)onEnter {
  [super onEnter];
  
  NSAssert(self.game != nil, @"Game object needs to be assigned before prematch scene is displayed");
  
  _playerNameLabel.string = [UserInfo sharedUserInfo].name;
  _opponentNameLabel.string = friendNameForUsername(getOpponentName(self.game));
  _currentRound.string = [self.game[@"movecount"] stringValue] ? [self.game[@"movecount"] stringValue] : @"1";
  
  [self fillRoundLabels];
}

- (void)startGame {
  CCScene *guessScene = [CCBReader loadAsScene:@"GameplayScene"];
  
  if ([self.game[@"gamestate"] isEqualToString:GAME_STATE_COMPLETED]) {
    // start a new game, since old one is completed
    self.game = @{@"opponent":getOpponentName(self.game)};
  }
  
  GameplayScene *gameplayScene = guessScene.children[0];
  gameplayScene.game = self.game;
  
  [[CCDirector sharedDirector] pushScene:guessScene];
}

- (void)backButtonPressed {
  [[CCDirector sharedDirector] popToRootScene];
}

#pragma mark - Fill User Interface

- (void)fillRoundLabels {
  NSDictionary *round1 = self.game[@"gamedata"][@"1"];
  NSDictionary *round2 = self.game[@"gamedata"][@"2"];
  NSDictionary *round3 = self.game[@"gamedata"][@"3"];
  
  NSString *playerUsername = [[UserInfo sharedUserInfo] username];
  NSString *opponentUsername = getOpponentName(self.game);
  
  BOOL round1Complete = [[self.game[@"gamedata"][@"1"] allKeys] count] == MOVES_PER_ROUND;
  BOOL round2Complete = [[self.game[@"gamedata"][@"2"] allKeys] count] == MOVES_PER_ROUND;
  BOOL round3Complete = [[self.game[@"gamedata"][@"3"] allKeys] count] == MOVES_PER_ROUND;
  
  NSInteger moveNumber = [self.game[@"movecount"] integerValue];
  
  if ((moveNumber % MOVES_PER_ROUND) == 0) {
    _actionInfoLabel.string = START_ROUND_STRING;
  } else {
    _actionInfoLabel.string = FINISH_ROUND_STRING;
  }
  
  if ([_currentRound.string isEqualToString:@"6"]) {
    NSInteger winner = calculateWinnerOfGame(self.game);
    
    if (winner == 0) {
      _actionInfoLabel.string = GAME_OVER_DRAW;
    } else if (winner == -1) {
      _actionInfoLabel.string = GAME_OVER_WIN;
    } else if (winner == 1) {
      _actionInfoLabel.string = GAME_OVER_LOSE;
    }
  }
  
  NSString *playerMoveRound1 = round1[playerUsername];
  _playerRound1.string = playerMoveRound1 ? playerMoveRound1 : @"_";
  NSString *opponentMoveRound1 = round1[opponentUsername];
  // only show choice of opponent if this round is complete
  if (opponentMoveRound1) {
    opponentMoveRound1 = round1Complete ? opponentMoveRound1 : @"?";
  }
  _opponentRound1.string = opponentMoveRound1 ? opponentMoveRound1: @"_";
  
  NSString *playerMoveRound2 = round2[playerUsername];
  _playerRound2.string = playerMoveRound2 ? playerMoveRound2 : @"_";
  NSString *opponentMoveRound2 = round2[opponentUsername];
  // only show choice of opponent if this round is complete
  if (opponentMoveRound2) {
    opponentMoveRound2 = round2Complete ? opponentMoveRound2 : @"?";
  }
  _opponentRound2.string = opponentMoveRound2 ? opponentMoveRound2: @"_";

  NSString *playerMoveRound3 = round3[playerUsername];
  _playerRound3.string = playerMoveRound3 ? playerMoveRound3 : @"_";
  NSString *opponentMoveRound3 = round3[opponentUsername];
  // only show choice of opponent if this round is complete
  if (opponentMoveRound3) {
    opponentMoveRound3 = round3Complete ? opponentMoveRound3 : @"?";
  }
  _opponentRound3.string = opponentMoveRound3 ? opponentMoveRound3: @"_";
}

@end
