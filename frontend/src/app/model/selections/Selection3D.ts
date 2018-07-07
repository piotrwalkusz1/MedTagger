import {ScanSelection} from './ScanSelection';
import {SliceSelection} from './SliceSelection';

export class Selection3D implements ScanSelection<SliceSelection> {
    _elements: SliceSelection[];

    constructor(elements?: SliceSelection[]) {
        this._elements = elements;
    }
    toJSON(): Object {
        const jsonObject: { elements: Object[] } = {elements: []};

        if (this._elements) {
            this._elements.forEach((element: SliceSelection) => {
                jsonObject.elements.push(element.toJSON());
            });
        }

        return jsonObject;
    }
}
