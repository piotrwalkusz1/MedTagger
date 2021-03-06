import {LabelTag} from '../labels/LabelTag';

export abstract class SliceSelection {

    private static nextId = 1;

    public sliceIndex: number;
    public pinned: boolean;
    public hidden: boolean;
    public label_tool: string;
    public label_tag: LabelTag;

    private id: number = SliceSelection.nextId++;

    public static resetIdCounter(): void {
        this.nextId = 1;
    }

    public getId(): number {
        return this.id;
    }

    protected setId(newId: number): void {
        this.id = newId;
    }

    public abstract toJSON(): Object;
    public getAdditionalData(): Object {
        return {};
    }
}
