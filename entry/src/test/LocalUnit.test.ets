import { describe, it, expect, beforeEach } from '@ohos/hypium';
import { Utils } from '../main/ets/Utils';
import { Box } from '../main/ets/model/Box';

function makeBoard(values: string[]): Box[] {
  return values.map(v => new Box(v));
}

export default function localUnitTest() {
  describe('Utils.detectWinner', () => {

    it('detects_row_0_win_X', 0, () => {
      // X X X
      // O O _
      // _ _ _
      const board = makeBoard(['X','X','X','O','O','','','','']);
      expect(Utils.detectWinner(board).winner).assertEqual('X');
    });

    it('detects_row_1_win_O', 0, () => {
      // X _ X
      // O O O
      // _ X _
      const board = makeBoard(['X','','X','O','O','O','','X','']);
      expect(Utils.detectWinner(board).winner).assertEqual('O');
    });

    it('detects_row_2_win_X', 0, () => {
      // O _ O
      // _ O _
      // X X X
      const board = makeBoard(['O','','O','','O','','X','X','X']);
      expect(Utils.detectWinner(board).winner).assertEqual('X');
    });

    it('detects_col_0_win_X', 0, () => {
      // X O _
      // X O _
      // X _ _
      const board = makeBoard(['X','O','','X','O','','X','','']);
      expect(Utils.detectWinner(board).winner).assertEqual('X');
    });

    it('detects_col_1_win_O', 0, () => {
      // X O _
      // _ O _
      // _ O X
      const board = makeBoard(['X','O','','','O','','','O','X']);
      expect(Utils.detectWinner(board).winner).assertEqual('O');
    });

    it('detects_col_2_win_X', 0, () => {
      // O _ X
      // O _ X
      // _ _ X
      const board = makeBoard(['O','','X','O','','X','','','X']);
      expect(Utils.detectWinner(board).winner).assertEqual('X');
    });

    it('detects_main_diagonal_win_O', 0, () => {
      // O X _
      // _ O X
      // _ _ O
      const board = makeBoard(['O','X','','','O','X','','','O']);
      expect(Utils.detectWinner(board).winner).assertEqual('O');
    });

    it('detects_anti_diagonal_win_X', 0, () => {
      // _ _ X
      // _ X _
      // X _ _
      const board = makeBoard(['','','X','','X','','X','','']);
      expect(Utils.detectWinner(board).winner).assertEqual('X');
    });

    it('returns_empty_on_partial_board', 0, () => {
      // _ _ _
      // _ X _
      // _ _ _
      const board = makeBoard(['','','','','X','','','','']);
      expect(Utils.detectWinner(board).winner).assertEqual('');
    });

    it('returns_empty_on_full_draw_board', 0, () => {
      // X O X
      // X O O
      // O X X
      const board = makeBoard(['X','O','X','X','O','O','O','X','X']);
      expect(Utils.detectWinner(board).winner).assertEqual('');
    });

  });

  describe('Utils.generateColor', () => {

    it('returns_blue_for_X', 0, () => {
      expect(Utils.generateColor('X')).assertEqual(Color.Blue);
    });

    it('returns_red_for_O', 0, () => {
      expect(Utils.generateColor('O')).assertEqual(Color.Red);
    });

    it('returns_gray_for_empty_string', 0, () => {
      expect(Utils.generateColor('')).assertEqual(Color.Gray);
    });

    it('returns_gray_for_unknown_value', 0, () => {
      expect(Utils.generateColor('Z')).assertEqual(Color.Gray);
    });

  });

  describe('Utils.generateBoxes', () => {

    beforeEach(() => {
      // Reset counter so each test starts from a clean ID sequence
      Box.resetCounter();
    });

    it('generates_9_boxes', 0, () => {
      const boxes = Utils.generateBoxes();
      expect(boxes.length).assertEqual(9);
    });

    it('all_boxes_are_empty', 0, () => {
      const boxes = Utils.generateBoxes();
      for (let i = 0; i < boxes.length; i++) {
        expect(boxes[i].value).assertEqual('');
      }
    });

    it('all_box_ids_are_unique', 0, () => {
      const boxes = Utils.generateBoxes();
      const ids = boxes.map(b => b.id);
      const uniqueIds = new Set(ids);
      expect(uniqueIds.size).assertEqual(9);
    });

    it('two_generations_have_no_id_collision', 0, () => {
      const first = Utils.generateBoxes();
      const second = Utils.generateBoxes();
      const firstIds = new Set(first.map(b => b.id));
      for (let i = 0; i < second.length; i++) {
        expect(firstIds.has(second[i].id)).assertFalse();
      }
    });

  });
}
